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
        @success="$emit('success', $event)"
        @error="$emit('error', $event)"
        @reset="resetData"
        @submit="$emit('submit', $event)"
      />
      <div
        v-if="withFooterSubmit"
        class="sticky-footer"
      >
        <VButton
          type="primary"
          long
          size="large"
          style="position: sticky; bottom: 0"
          @click="submit"
        >
          Submit
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
    formId: {
      type: Number,
      required: false,
      default: null
    }
  },
  emits: ['submit', 'success', 'error', 'loaded'],
  data () {
    return {
      formData: {},
      dataForm: {},
      variableWatchers: {},
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
      this.$refs.form.handleSubmit()
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
      this.formData = { ...this.data }

      this.loadData()
    },
    loadData () {
      const hasVariablesSet = this.intialDataVariables.every((variable) => {
        return ![null, undefined, ''].includes(this.customFormComponentData[variable])
      })

      if (this.dataForm.preferences.default_values_api_path && hasVariablesSet) {
        const path = interpolate(this.dataForm.preferences.default_values_api_path, this.customFormComponentData)

        return loadCredentials().then((credentials) => {
          return axios.get(path, {
          }, {
            headers: {
              ...this.headers,
              ...credentials.headers
            }
          }).then((result) => {
            this.formData = { ...this.data, ...result.data }
          }).catch((error) => {
            console.error(error)

            if (error.response.data?.errors) {
              this.$Message.error(truncate(error.response.data.errors.join('\n'), 70))
            } else {
              this.$Message.error('Unable to load form data')
            }
          })
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
