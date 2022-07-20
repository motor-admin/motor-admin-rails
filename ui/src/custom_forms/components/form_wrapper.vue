<template>
  <div>
    <Spin
      v-if="isLoading"
      fix
    />
    <template v-else>
      <CustomForm
        ref="form"
        :form="dataForm"
        :data="formData"
        :with-submit="!withFooterSubmit"
        :with-success-message="withSuccessMessage"
        :with-go-back="withGoBack"
        :exclude-fields="excludeFields"
        :submit-button-size="submitButtonSize"
        @success="onSuccess"
        @error="$emit('error', $event)"
        @reset="resetData"
        @submit="$emit('submit', $event)"
        @back="$emit('back')"
      />
      <div
        v-if="withFooterSubmit && !isSuccess"
        class="sticky-footer"
      >
        <VButton
          type="primary"
          long
          :size="submitButtonSize"
          :disabled="isSubmitting"
          :loading="isSubmitting"
          style="position: sticky; bottom: 0"
          @click="submit"
        >
          {{ i18n['submit'] }}
        </VButton>
      </div>
    </template>
  </div>
</template>

<script>
import CustomForm from './custom_form'
import { interpolate, truncate } from 'utils/scripts/string'
import { loadCredentials } from 'utils/scripts/auth_credentials'
import api from 'api'
import axios from 'axios'
import { watch } from 'vue'

function isObject (value) {
  return typeof value === 'object' && value !== null && !Array.isArray(value)
}

export default {
  name: 'CustomFormWrapper',
  components: {
    CustomForm
  },
  props: {
    data: {
      type: Object,
      required: false,
      default: () => ({})
    },
    form: {
      type: Object,
      required: false,
      default: null
    },
    withFooterSubmit: {
      type: Boolean,
      required: false,
      default: false
    },
    withSuccessMessage: {
      type: Boolean,
      required: false,
      default: true
    },
    formId: {
      type: [String, Number],
      required: false,
      default: null
    },
    triggerRequest: {
      type: Boolean,
      required: false,
      default: true
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
    },
    withGoBack: {
      type: Boolean,
      required: false,
      default: false
    }
  },
  emits: ['submit', 'success', 'error', 'loaded', 'submitData', 'back'],
  data () {
    return {
      formData: {},
      dataForm: {},
      variableWatchers: {},
      isSuccess: false,
      isLoading: true,
      isSubmitting: false
    }
  },
  computed: {
    intialDataVariables () {
      if (this.dataForm.preferences.default_values_api_path) {
        const matched = this.dataForm.preferences.default_values_api_path.match(/{{?(\w+)}}?/g)

        return matched ? matched.map((string) => string.replace(/[{}]/g, '')) : []
      } else if (this.dataForm.preferences.graphql_query) {
        return this.dataForm.preferences.graphql_query.match(/(\$\w+)/g)
          .filter((v, i, a) => a.indexOf(v) === i)
          .map((string) => string.replace('$', ''))
      } else {
        return []
      }
    }
  },
  watch: {
    'dataForm.preferences.default_values_api_path' (value) {
      this.assignInitialDataVariablesWatchers()
    },
    'dataForm.preferences.graphql_query' (value) {
      this.assignInitialDataVariablesWatchers()
    },
    isLoading (value) {
      if (!value) {
        this.$nextTick(() => {
          this.assignInitialDataVariablesWatchers()

          watch(
            () => this.$refs.form.formData,
            (value) => {
              this.assignInitialDataVariablesWatchers()
            }
          )

          watch(
            () => this.$refs.form.isSubmitting,
            (value) => {
              this.isSubmitting = value
            }
          )
        })
      }
    },
    data () {
      this.formData = { ...this.data }

      this.loadData()
    },
    form () {
      this.dataForm = { ...this.form }

      this.loadData()
    }
  },
  async created () {
    this.formData = { ...this.data }

    if (!this.form) {
      await this.loadForm()
    } else {
      this.dataForm = { ...this.form }
    }

    await this.loadData()

    this.isLoading = false
    this.$emit('loaded', this.dataForm)
  },
  methods: {
    submit () {
      if (this.triggerRequest) {
        this.$refs.form.handleSubmit()
      } else {
        this.$refs.form.validate((valid) => {
          if (valid) {
            this.$emit('submitData', this.formData)
          } else {
            this.$refs.form.scrollToErrors()
          }
        })
      }
    },
    assignInitialDataVariablesWatchers () {
      const formData = this.$refs.form?.formData || this.formData

      this.intialDataVariables.forEach(variable => {
        this.variableWatchers[variable] = watch(
          () => formData[variable],
          (value) => {
            if (value || value === false || value === 0) {
              this.loadData()
            }
          }
        )
      })
    },
    resetData () {
      this.isSuccess = false
      this.formData = { ...this.data }

      this.isLoading = true

      this.loadData().finally(() => {
        this.isLoading = false
      })
    },
    onSuccess (data) {
      this.isSuccess = true

      this.$emit('success', data)
    },
    loadData () {
      const formData = this.$refs.form?.formData || this.formData

      const hasVariablesSet = this.intialDataVariables.some((variable) => {
        return ![null, undefined, ''].includes(formData[variable])
      }) || Object.keys(this.intialDataVariables).length === 0

      if ((this.dataForm.preferences.default_values_api_path || this.dataForm.preferences.graphql_query) && hasVariablesSet) {
        let request

        if (this.dataForm.preferences.request_type === 'graphql') {
          request = api.post('run_graphql_request', {
            data: {
              query: this.dataForm.preferences.graphql_query,
              api_config_name: this.dataForm.api_config_name,
              variables: formData
            }
          })
        } else {
          const path = interpolate(this.dataForm.preferences.default_values_api_path, formData)

          if (this.dataForm.api_config_name !== 'origin' && !path.startsWith(location.origin)) {
            request = api.get('run_api_request', {
              params: {
                data: {
                  api_config_name: this.dataForm.api_config_name,
                  path
                }
              }
            })
          } else {
            request = loadCredentials().then((credentials) => {
              return axios.get(path, {
                headers: credentials.headers
              })
            })
          }
        }

        return request.then((result) => {
          if (result.data?.errors) {
            this.$Message.error(truncate(result.data.errors.map(e => e.message).join('\n'), 70))
          } else {
            if (result.data.data && Object.keys(result.data.data).length === 1 && isObject(Object.values(result.data.data)[0])) {
              this.formData = { ...this.data, ...Object.values(result.data.data)[0] }
            } else if (isObject(result.data.data)) {
              this.formData = { ...this.data, ...result.data.data }
            } else {
              this.formData = { ...this.data, ...result.data }
            }
          }
        }).catch((error) => {
          console.error(error)

          if (error.response.data?.errors) {
            this.$Message.error(truncate(error.response.data.errors.join('\n'), 70))
          } else {
            this.$Message.error(this.i18n.unable_to_load_form_data)
          }
        })
      } else {
        return Promise.resolve({})
      }
    },
    loadForm () {
      return api.get(`forms/${this.formId}`, {
      }).then((result) => {
        this.dataForm = result.data.data
      }).catch((error) => {
        console.error(error)

        if (error.response.data?.errors) {
          this.$Message.error(error.response.data.errors.join('\n'))
        }
      })
    }
  }
}
</script>
