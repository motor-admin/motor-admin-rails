<template>
  <div
    class="row mx-2"
    style="min-height: 74px"
  >
    <div class="col-8">
      <h1
        v-if="Object.keys(alert).length"
        class="my-3"
      >
        {{ alert.name || 'New alert' }}
      </h1>
    </div>
    <div class="col-4 d-flex align-items-center justify-content-end">
      <VButton
        v-if="alert.id"
        size="large"
        class="bg-white ms-2"
        :loading="isEnabledToggleLoading"
        :icon="alert.is_enabled ? 'md-close' : 'md-checkmark'"
        @click="toggleEnabled"
      >
        {{ alert.is_enabled ? 'Disable' : 'Activate' }}
      </VButton>
      <VButton
        v-if="alert.query_id && alert.to_emails.length"
        size="large"
        icon="md-send"
        :loading="isSendingLoading"
        class="bg-white ms-2"
        @click="sendNow"
      >
        Send Now
      </VButton>
      <VButton
        size="large"
        ghost
        type="primary"
        class="bg-white ms-2"
        @click="onSaveClick"
      >
        Save
      </VButton>
    </div>
  </div>
  <div
    class="row border-top m-0"
    :style="{ height: 'calc(100vh - 134px)' }"
  >
    <div
      class="col-6 col-lg-7 d-none d-md-block p-0 text-center"
      style="height: 100%; overflow: scroll; position: relative"
    >
      <Spin
        v-if="isLoadingQuery || isLoadingAlert"
        fix
      />
      <QueryResult
        v-if="alert.query_id"
        :data="data"
        :errors="errors"
        :borderless="true"
        :with-settings="false"
        :columns="columns"
      />
      <p
        v-else-if="!isLoadingQuery && !isLoadingAlert"
        class="mt-5"
      >
        Query not selected
      </p>
    </div>
    <div
      class="col-12 col-md-6 col-lg-5 border-left bg-white p-3"
      style="height: 100%; overflow: scroll; position: relative"
    >
      <Spin
        v-if="isLoadingAlert"
        fix
      />
      <AlertForm
        v-else
        ref="form"
        :alert="alert"
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
import api from 'api'

const defaultAlertParams = {
  name: '',
  description: '',
  to_emails: [],
  query_id: null,
  preferences: {}
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

      api.post('api/send_alerts', {
        data: {
          query_id: this.alert.query_id,
          to_emails: this.alert.to_emails.join(','),
          name: this.alert.name
        }
      }).then((result) => {
        this.$Message.info('Alert email has been sent!')
      }).finally(() => {
        this.isSendingLoading = false
      })
    },
    toggleEnabled () {
      this.isEnabledToggleLoading = true

      api.put(`api/alerts/${this.alert.id}`, {
        data: {
          is_enabled: !this.alert.is_enabled
        }
      }).then((result) => {
        this.alert.is_enabled = result.data.data.is_enabled

        this.$Message.info(`Alert has been ${this.alert.is_enabled ? 'activated' : 'disabled'}`)
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
        return api.put(`api/alerts/${alert.id}`, { data, include: 'tags' })
      } else {
        return api.post('api/alerts', { data, include: 'tags' })
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
        this.alert = this.normalizeAlert(result.data.data)

        this.$router.push({ name: 'alert', params: { id: this.alert.id } })

        this.$Message.info('Alert has been saved!')
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
    normalizeAlert (alert) {
      return {
        ...alert,
        to_emails: alert.to_emails.split(','),
        tags: alert.tags.map((tag) => tag.name)
      }
    },
    loadAlert () {
      this.isLoadingAlert = true

      return api.get(`api/alerts/${this.$route.params.id}`, {
        params: {
          include: 'tags'
        }
      }).then((result) => {
        this.alert = this.normalizeAlert(result.data.data)
      }).catch((error) => {
        console.error(error)
      }).finally(() => {
        this.isLoadingAlert = false
      })
    },
    loadQuery () {
      this.isLoadingQuery = true

      return api.get(`api/run_queries/${this.alert.query_id}`, {
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
