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
      isLoading: true
    }
  },
  computed: {
    customFormComponentData () {
      return this.$refs.form.formData
    },
    intialDataVariables () {
      if (this.dataForm.preferences.default_values_api_path) {
        const matched = this.dataForm.preferences.default_values_api_path.match(/{{?(\w+)}}?/g)

        return matched ? matched.map((string) => string.replace(/[{}]/g, '')) : []
      } else {
        return []
      }
    }
  },
  watch: {
    'dataForm.preferences.default_values_api_path' (value) {
      this.assignInitialDataVariablesWatchers()
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

    this.assignInitialDataVariablesWatchers()
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
      this.intialDataVariables.forEach(variable => {
        this.variableWatchers[variable] ||= watch(
          () => this.customFormComponentData[variable],
          (value) => {
            if (value) {
              this.loadData()
            }
          }
        )
      })
    },
    resetData () {
      this.isSuccess = false
      this.formData = { ...this.data }

      this.loadData()
    },
    onSuccess (data) {
      this.isSuccess = true

      this.$emit('success', data)
    },
    loadData () {
      const hasVariablesSet = this.intialDataVariables.every((variable) => {
        return ![null, undefined, ''].includes(this.customFormComponentData[variable])
      })

      if (this.dataForm.preferences.default_values_api_path && hasVariablesSet) {
        const path = interpolate(this.dataForm.preferences.default_values_api_path, this.customFormComponentData)

        let request

        if (this.dataForm.api_config_name !== 'origin') {
          request = api.get('run_api_request', {
            params: {
              data: {
                api_config_name: this.dataForm.api_config_name,
                path: path
              }
            }
          })
        } else {
          request = loadCredentials().then((credentials) => {
            return axios.get(path, {
            }, {
              headers: {
                ...this.headers,
                ...credentials.headers
              }
            })
          })
        }

        return request.then((result) => {
          this.formData = { ...this.data, ...result.data }
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
