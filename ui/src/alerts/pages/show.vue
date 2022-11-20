<template>
  <div
    class="row mx-0 mx-md-2"
    style="min-height: 74px"
  >
    <div class="col-7 col-md-8 d-flex align-items-center">
      <h1
        class="my-3 overflow-hidden text-truncate"
      >
        {{ alert.name || cachedAlertName || i18n['new_alert'] }}
      </h1>
    </div>
    <div class="col-5 col-md-4 d-flex align-items-center justify-content-end">
      <VButton
        v-if="alert.id && $can('update', 'Motor::Alert')"
        size="large"
        class="bg-white ms-2 md-icon-only"
        :loading="isEnabledToggleLoading"
        :icon="alert.is_enabled ? 'md-close' : 'md-checkmark'"
        @click="toggleEnabled"
      >
        {{ alert.is_enabled ? i18n['disable'] : i18n['activate'] }}
      </VButton>
      <VButton
        v-if="alert.query_id && (alert.to_emails.length || alert.preferences.adapter === 'slack') && $can('manage', 'Motor::Alert')"
        size="large"
        icon="md-send"
        :loading="isSendingLoading"
        class="bg-white ms-2 md-icon-only"
        @click="sendNow"
      >
        {{ i18n['send_now'] }}
      </VButton>
      <VButton
        v-if="isCanEdit"
        size="large"
        ghost
        type="primary"
        class="bg-white ms-2"
        @click="onSaveClick"
      >
        {{ i18n['save'] }}
      </VButton>
    </div>
  </div>
  <div
    class="row border-top m-0"
    :style="{ height: 'calc(var(--vh, 100vh) - 134px)' }"
  >
    <div
      class="col-6 col-lg-7 d-none d-md-block p-0"
      style="height: 100%; position: relative"
    >
      <Spin
        v-if="isLoadingQuery || isLoadingAlert"
        fix
      />
      <div
        v-else-if="!data.length"
        class="d-flex justify-content-center align-items-center"
        style="height: 100%"
      >
        {{ i18n['no_data'] }}
      </div>
      <QueryResult
        v-else-if="alert.query_id"
        :data="data"
        :errors="errors"
        :borderless="true"
        :preferences="alert.query?.preferences"
        :with-settings="false"
        :columns="columns"
      />
      <p
        v-else-if="!isLoadingQuery && !isLoadingAlert"
        class="mt-5"
      >
        {{ i18n['query_not_selected'] }}
      </p>
    </div>
    <div
      class="col-12 col-md-6 col-lg-5 border-left bg-white p-3"
      style="height: 100%; overflowY: auto; position: relative"
    >
      <Spin
        v-if="isLoadingAlert"
        fix
      />
      <AlertForm
        v-else
        ref="form"
        :alert="alert"
        :with-submit="isCanEdit"
        :loading="isSubmitting"
        @submit="onSubmit"
        @select-query="onSelectQuery"
        @change-emails="alert.to_emails = $event"
      />
    </div>
  </div>
</template>

<script>
import AlertForm from '../components/form'
import QueryResult from 'queries/components/result'
import { alertsStore } from 'reports/scripts/store'
import api from 'api'

const defaultAlertParams = {
  name: '',
  description: '',
  to_emails: '',
  query_id: null,
  tags: [],
  preferences: { adapter: 'email' }
}

export default {
  name: 'NewAlert',
  components: {
    AlertForm,
    QueryResult
  },
  data () {
    return {
      isSendingLoading: false,
      isEnabledToggleLoading: false,
      isSubmitting: false,
      isLoadingQuery: false,
      isLoadingAlert: false,
      data: [],
      columns: [],
      errors: [],
      alert: {}
    }
  },
  computed: {
    cachedAlertName () {
      return alertsStore.find((q) => q.id.toString() === this.$route.params?.id)?.name
    },
    isCanEdit () {
      return this.alert.id ? this.$can('edit', 'Motor::Alert', this.alert) : this.$can('create', 'Motor::Alert')
    }
  },
  watch: {
    '$route' (to, from) {
      if (['alert', 'new_alert'].includes(to.name)) {
        const isNewAlert = to.params.id !== this.alert.id?.toString()

        if (isNewAlert) {
          this.onMounted()
        }
      }
    }
  },
  created () {
    this.onMounted()
  },
  methods: {
    onSelectQuery (queryId) {
      this.alert.query_id = queryId

      if (queryId) {
        this.loadQuery()
      }
    },
    sendNow () {
      this.isSendingLoading = true

      api.post('send_alerts', {
        data: {
          query_id: this.alert.query_id,
          to_emails: this.alert.to_emails,
          description: this.alert.description,
          name: this.alert.name,
          preferences: this.alert.preferences
        }
      }).then((result) => {
        this.$Message.info(this.i18n.alert_email_has_been_sent)
      }).catch((error) => {
        console.error(error)

        if (error.response.data?.errors?.length) {
          this.$Message.error(error.response.data.errors.join('\n'))
        } else {
          this.$Message.error(this.i18n.unable_to_send_email)
        }
      }).finally(() => {
        this.isSendingLoading = false
      })
    },
    toggleEnabled () {
      this.isEnabledToggleLoading = true

      api.put(`alerts/${this.alert.id}`, {
        data: {
          is_enabled: !this.alert.is_enabled
        }
      }).then((result) => {
        this.alert.is_enabled = result.data.data.is_enabled

        this.$Message.info(this.alert.is_enabled ? this.i18n.alert_has_been_activated : this.i18n.alert_has_been_disabled)
      }).catch((error) => {
        if (error.response.data?.errors?.length) {
          this.$Message.error(error.response.data.errors.join('\n'))
        }
      }).finally(() => {
        this.isEnabledToggleLoading = false
      })
    },
    submitRequest (alert) {
      const data = {
        ...alert,
        to_emails: alert.to_emails.join(',')
      }

      if (alert.id) {
        return api.put(`alerts/${alert.id}`, { data, include: 'tags' })
      } else {
        return api.post('alerts', { data, include: 'tags' })
      }
    },
    onMounted () {
      if (this.$route.params.id) {
        this.loadAlert().then(() => {
          this.loadQuery()
        })
      } else {
        this.alert = { ...defaultAlertParams }
        this.alert.query_id = this.$route.query?.query_id
      }
    },
    onSubmit (alert) {
      this.isSubmitting = true

      this.submitRequest(alert).then((result) => {
        this.alert = result.data.data

        this.$router.push({ name: 'alert', params: { id: this.alert.id } })

        this.$Message.info(this.i18n.alert_has_been_saved)
      }).catch((error) => {
        if (error.response?.data?.errors?.length) {
          this.$refs.form.$refs.form.setErrors(error.response.data.errors)
        } else {
          console.error(error)
        }
      }).finally(() => {
        this.isSubmitting = false
      })
    },
    onSaveClick () {
      this.$refs.form.submit()
    },
    loadAlert () {
      this.isLoadingAlert = true

      return api.get(`alerts/${this.$route.params.id}`, {
        params: {
          include: 'tags,query'
        }
      }).then((result) => {
        this.alert = result.data.data
      }).catch((error) => {
        console.error(error)

        if (error.response?.data?.errors) {
          this.$Message.error(error.response.data.errors.join('\n'))
        } else {
          this.$Message.error(error.message)
        }
      }).finally(() => {
        this.isLoadingAlert = false
      })
    },
    loadQuery () {
      this.isLoadingQuery = true

      return api.get(`run_queries/${this.alert.query_id}`, {
      }).then((result) => {
        this.data = result.data.data
        this.columns = result.data.meta.columns
      }).catch((error) => {
        console.error(error)
      }).finally(() => {
        this.isLoadingQuery = false
      })
    }
  }
}
</script>
