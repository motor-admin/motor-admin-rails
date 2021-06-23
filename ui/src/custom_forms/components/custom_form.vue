<template>
  <div v-if="isSuccess">
    <p class="fs-2 fw-bold text-center mb-2">
      <Icon
        type="md-checkmark-circle-outline"
        class="text-success"
      />
      {{ i18n['form_has_been_submitted_successfully'] }}
    </p>
    <div
      v-if="successData"
      class="mb-2"
    >
      <pre v-if="typeof successData === 'object'">{{ JSON.stringify(successData, null, '  ') }}</pre>
      <div
        v-else
        v-html="safeSuccessData"
      />
    </div>
    <VButton
      icon="md-refresh"
      size="large"
      ghost
      long
      type="primary"
      @click="reset"
    >
      {{ i18n['resubmit'] }}
    </VButton>
  </div>
  <VForm
    v-else
    ref="form"
    :model="formData"
    label-position="top"
    @submit.prevent="handleSubmit"
  >
    <FormItems
      v-model:form-data="formData"
      :items="fields"
    />
    <VButton
      v-if="withSubmit"
      type="primary"
      long
      size="large"
      style="position: sticky; bottom: 0"
      :disabled="isSubmitDisabled"
      @click="handleSubmit"
    >
      {{ i18n['submit'] }}
    </VButton>
  </VForm>
  <Spin
    v-if="isLoading"
    fix
  />
</template>

<script>
import FormItems from './form_items'
import { interpolate } from 'utils/scripts/string'
import { loadCredentials } from 'utils/scripts/auth_credentials'
import { scrollToErrors } from 'data_forms/scripts/form_utils'
import { buildDefaultValues } from '../scripts/utils'
import axios from 'axios'
import DOMPurify from 'dompurify'

export default {
  name: 'DataForm',
  components: {
    FormItems
  },
  props: {
    data: {
      type: Object,
      required: false,
      default: () => ({})
    },
    form: {
      type: Object,
      required: true
    },
    withSubmit: {
      type: Boolean,
      required: false,
      default: false
    }
  },
  emits: ['submit', 'success', 'error', 'reset'],
  data () {
    return {
      isLoading: false,
      isSuccess: false,
      successData: null,
      formData: {}
    }
  },
  computed: {
    safeSuccessData () {
      return DOMPurify.sanitize(this.successData)
    },
    headers () {
      const headers = {}
      const csrfTag = document.querySelector('[name="csrf-token"]')

      if (csrfTag) {
        headers['X-CSRF-Token'] = csrfTag.content
      }

      return headers
    },
    isSubmitDisabled () {
      return !this.form.api_path
    },
    fields () {
      return this.form.preferences.fields
    }
  },
  watch: {
    data () {
      this.formData = { ...this.formData, ...buildDefaultValues(this.fields), ...this.data }
    },
    form () {
      this.formData = { ...this.formData, ...buildDefaultValues(this.fields), ...this.data }
    }
  },
  created () {
    this.formData = { ...buildDefaultValues(this.fields), ...this.data }
  },
  methods: {
    scrollToErrors,
    reset () {
      this.formData = {}
      this.$parent.resetData()

      this.isSuccess = false
      this.successData = null

      this.formData = { ...buildDefaultValues(this.fields), ...this.$parent.formData }
    },
    sendData () {
      const path = interpolate(this.form.api_path, this.formData)
      const method = this.form.http_method.toLowerCase()

      this.isLoading = true

      loadCredentials().then((credentials) => {
        return axios[method](path, {
          ...this.formData
        }, {
          headers: {
            ...this.headers,
            ...credentials.headers
          }
        }).then((result) => {
          this.$emit('success', result)
          this.isSuccess = true
          this.successData = result.data
        }).catch((error) => {
          console.error(error)

          if (error.response?.data?.errors) {
            this.$refs.form.setErrors(error.response.data.errors)
            this.scrollToErrors()
          } else {
            this.$Message.error(`${this.i18n.unable_to_submit_form}: ${error.response.status}`)
          }

          this.$emit('error', error)
        }).finally(() => {
          this.isLoading = false
          this.$emit('submit', this.formData)
        })
      })
    },
    handleSubmit () {
      if (!this.isSubmitDisabled) {
        this.$refs.form.validate((valid) => {
          if (valid) {
            this.sendData()
          } else {
            this.scrollToErrors()
          }
        })
      }
    }
  }
}
</script>
