<template>
  <div v-if="isSuccess && withSuccessMessage">
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
      <pre
        v-if="typeof successData === 'object'"
        style="white-space: break-spaces"
      >{{ JSON.stringify(successData, null, '  ') }}</pre>
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
    <VButton
      v-if="withGoBack"
      icon="md-arrow-back"
      size="large"
      long
      type="primary"
      class="mt-3"
      @click="$emit('back')"
    >
      {{ i18n['go_back'] }}
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
      :variables-data="formData"
      :items="fields"
    />
    <VButton
      v-if="withSubmit"
      type="primary"
      long
      :size="submitButtonSize"
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
import api from 'api'
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
    withSuccessMessage: {
      type: Boolean,
      required: false,
      default: true
    },
    withSubmit: {
      type: Boolean,
      required: false,
      default: false
    },
    withGoBack: {
      type: Boolean,
      required: false,
      default: false
    },
    excludeFields: {
      type: Array,
      required: false,
      default: () => ([])
    },
    submitButtonSize: {
      type: String,
      required: false,
      default: 'large'
    }
  },
  emits: ['submit', 'success', 'error', 'reset', 'back'],
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
      return this.form.preferences.fields.filter((field) => !this.excludeFields.includes(field.name))
    }
  },
  watch: {
    data () {
      this.formData = { ...buildDefaultValues(this.fields), ...this.formData, ...this.data }
    },
    form () {
      this.formData = { ...buildDefaultValues(this.fields), ...this.formData, ...this.data }
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
      let request

      this.isLoading = true

      if (this.form.api_config_name !== 'origin') {
        request = api.post('run_api_request', {
          data: {
            body: this.formData,
            api_config_name: this.form.api_config_name,
            path,
            method
          }
        })
      } else {
        request = loadCredentials().then((credentials) => {
          return axios[method](path, {
            ...this.formData
          }, {
            headers: {
              ...this.headers,
              ...credentials.headers
            }
          })
        })
      }

      return request.then((result) => {
        const redirectTo = result.data?.redirect || result.data?.redirect_to || result.redirect || result.redirect_to

        if (typeof redirectTo === 'string') {
          const resolvedRoute = this.$router.resolve({ path: redirectTo.replace(location.origin, '') }, this.$route)

          if (resolvedRoute?.name) {
            this.$router.push(resolvedRoute)
          } else {
            location.href = redirectTo
          }
        } else {
          this.isSuccess = true
          this.successData = result.data
        }

        this.$emit('success', result)
      }).catch((error) => {
        console.error(error)

        if (error.response?.data?.errors) {
          this.$refs.form.setErrors(error.response.data.errors)
          this.scrollToErrors()
        } else {
          this.$refs.form.setErrors([`${this.i18n.unable_to_submit_form}: ${error.response?.status || error.message}`])
        }

        this.$emit('error', error)
      }).finally(() => {
        this.isLoading = false
        this.$emit('submit', this.formData)
      })
    },
    validate (validate) {
      this.$refs.form.validate(validate)
    },
    handleSubmit () {
      if (!this.isSubmitDisabled) {
        this.validate((valid) => {
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
