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
    :data-form-edited="isEdited"
    @submit.prevent="handleSubmit"
  >
    <FormItems
      v-model:form-data="formData"
      :variables-data="formData"
      :items="fields"
      @edit="isEdited = true"
    />
    <VButton
      v-if="withSubmit"
      type="primary"
      long
      :size="submitButtonSize"
      :disabled="isSubmitDisabled || isSubmitting"
      :loading="isSubmitting"
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
  provide () {
    return {
      formComponent: this
    }
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
      isEdited: false,
      isLoading: false,
      isSuccess: false,
      isSubmitting: false,
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
      return !this.form.api_path && !this.form.preferences.graphql_mutation
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
      this.formData = { ...buildDefaultValues(this.fields), ...this.$parent.formData }
      this.$parent.resetData()

      this.isSuccess = false
      this.successData = null
    },
    sendData () {
      const path = interpolate(this.form.api_path, this.formData)
      const method = this.form.http_method.toLowerCase()
      let request

      this.isLoading = true

      if (this.form.api_config_name !== 'origin') {
        if (this.form.preferences.request_type === 'graphql') {
          request = api.post('run_graphql_request', {
            data: {
              query: this.form.preferences.graphql_mutation,
              api_config_name: this.form.api_config_name,
              variables: this.formData
            }
          }, {
            responseType: 'blob'
          })
        } else {
          request = api.post('run_api_request', {
            data: {
              body: this.formData,
              api_config_name: this.form.api_config_name,
              path,
              method
            }
          }, {
            responseType: 'blob'
          })
        }
      } else {
        request = loadCredentials().then((credentials) => {
          return axios[method](path, {
            ...this.formData
          }, {
            responseType: 'blob',
            headers: {
              ...this.headers,
              ...credentials.headers
            }
          })
        })
      }

      return request.then((result) => {
        const blob = result.data

        blob.text().then(text => {
          try {
            result.data = JSON.parse(text)
          } catch (e) {
            result.data = text
          }

          if (result.data?.errors) {
            this.$refs.form.setErrors(result.data.errors)
            this.scrollToErrors()

            this.$emit('error', result)
          } else {
            const redirectTo = result.data?.redirect || result.data?.redirect_to || result.redirect || result.redirect_to

            if (typeof redirectTo === 'string') {
              const resolvedRoute = this.$router.resolve({ path: redirectTo.replace(location.origin, '') }, this.$route)

              if (resolvedRoute?.name) {
                this.$router.push(resolvedRoute)
              } else {
                location.href = redirectTo
              }
            } else if (result.headers['content-disposition']?.startsWith('attachment')) {
              const fileName = result.headers['content-disposition'].match(/filename="(.*?)"/)?.[1]
              const dataUrl = URL.createObjectURL(blob)

              const link = document.createElement('a')

              link.setAttribute('href', dataUrl)
              link.setAttribute('download', `${fileName || 'attachment'}`)

              link.click()

              this.successData = '<div class="text-center">File attachment has started downloading</div>'
            } else {
              this.successData = result.data
            }

            this.isSuccess = true

            this.$emit('success', result)
          }
        })
      }).catch((error) => {
        console.error(error)

        error.response.data.text().then(text => {
          try {
            error.response.data = JSON.parse(text)
          } catch (e) {
            error.response.data = text
          }

          if (error.response?.data?.errors) {
            this.$refs.form.setErrors(error.response.data.errors)
            this.scrollToErrors()
          } else {
            this.$refs.form.setErrors([`${this.i18n.unable_to_submit_form}: ${error.response?.status || error.message}`])
          }

          this.$emit('error', error)
        })
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
