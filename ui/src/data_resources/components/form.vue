<template>
  <VForm
    ref="form"
    :model="resourceData"
    :rules="rules"
    label-position="top"
  >
    <FormItem
      v-for="column in columns"
      :key="column.name"
      :label="column.display_name"
      :prop="column.name"
    >
      <FormListInput
        v-if="column.is_array"
        v-model="resourceData[column.name]"
        :column="column"
      />
      <FormInput
        v-else
        v-model="resourceData[column.name]"
        :column="column"
      />
    </FormItem>
  </VForm>
  <div class="drawer-footer">
    <VButton
      style="float: left"
      @click.stop="$emit('close')"
    >
      Cancel
    </VButton>
    <VButton
      v-if="action === 'new'"
      type="primary"
      ghost
      class="bg-white me-2"
      :loading="isSaveAndNewLoading"
      @click.stop="onSaveAndCreateClick"
    >
      Save and Create New
    </VButton>
    <VButton
      type="primary"
      :loading="isSaveLoading"
      @click.stop="onSaveClick"
    >
      Save
    </VButton>
  </div>
</template>

<script>
import api from 'api'
import { modelNameMap } from '../scripts/schema'

import Validators from 'utils/scripts/validators'
import FormInput from 'data_forms/components/input'
import FormListInput from 'data_forms/components/list_input'

export default {
  name: 'ResourceForm',
  components: {
    FormInput,
    FormListInput
  },
  props: {
    resource: {
      type: Object,
      required: false,
      default () {
        return {}
      }
    },
    action: {
      type: String,
      required: false,
      default: 'new',
      validator (value) {
        return ['edit', 'new'].includes(value)
      }
    },
    resourceName: {
      type: String,
      required: true
    }
  },
  emits: ['close', 'success'],
  data () {
    return {
      isSaveAndNewLoading: false,
      isSaveLoading: false,
      resourceData: {}
    }
  },
  computed: {
    rules () {
      return this.columns.reduce((acc, column) => {
        if (column.is_array) {
          return acc
        }

        acc[column.name] = column.validators.map((validator) => {
          if (validator.required) {
            return { required: true }
          } else if (validator.format) {
            return { pattern: new RegExp(validator.format.source, validator.format.options) }
          } else if (validator.includes) {
            return { required: true }
          } else if (validator.length) {
            return { len: validator.length }
          } else if (validator.numeric) {
            return [
              { type: 'number' },
              { required: !validator.numeric.allow_nil },
              {
                required: !validator.numeric.allow_nil,
                validator: Validators.numeric,
                options: validator.numeric
              }
            ]
          } else {
            return null
          }
        }).filter(Boolean).flat()

        if (column.name === 'email') {
          acc[column.name].push({ type: 'email' })
        }

        if (this.isJsonColumn(column)) {
          acc[column.name].push({ validator: Validators.json })
        }

        if (!column.reference && ['integer', 'float'].includes(column.column_type)) {
          acc[column.name].push({ type: 'number' })
        }

        return acc
      }, {})
    },
    model () {
      return modelNameMap[this.resourceName]
    },
    requestParams () {
      const data = {
        ...this.resourceData
      }

      this.columns.forEach((column) => {
        if (this.isJsonColumn(column)) {
          data[column.name] = JSON.parse(data[column.name])
        }

        if (this.action === 'edit' && JSON.stringify(this.resource[column.name]) === JSON.stringify(data[column.name])) {
          delete data[column.name]
        } else if (column.reference?.model_name === 'active_storage/attachment') {
          data[column.name.replace(/_attachment$/, '')] = data[column.name]

          delete data[column.name]
        }
      })

      return { data }
    },
    apiRequest () {
      if (this.action === 'edit') {
        return api.put(`data/${this.model.slug}/${this.resource[this.model.primary_key]}`, this.requestParams)
      } else if (this.action === 'new') {
        return api.post(`data/${this.model.slug}`, this.requestParams)
      } else {
        return null
      }
    },
    columns () {
      const accessTypes = ['read_write', 'write_only']

      return this.model.columns.filter((column) => {
        return accessTypes.includes(column.access_type)
      })
    }
  },
  created () {
    this.resourceData = this.normalizeResourceData(this.resource)
  },
  methods: {
    isJsonColumn (column) {
      return (column.column_type === 'json' ||
        (this.resource[column.name] instanceof Object &&
        this.resource[column.name].constructor === Object)) &&
        !['file', 'image'].includes(column.column_type)
    },
    scrollToErrors () {
      this.$nextTick(() => {
        const errorField = this.$refs.form.$el.querySelector('.ivu-form-item-error')

        if (errorField) {
          errorField.scrollIntoView()
        } else {
          this.$refs.form.$el.querySelector('.ivu-alert-error')?.scrollIntoView()
        }
      })
    },
    onSaveClick () {
      this.$refs.form.validate((valid) => {
        if (valid) {
          this.isSaveLoading = true

          this.handleSubmit({ button: 'save' })
        } else {
          this.scrollToErrors()
        }
      })
    },
    onSaveAndCreateClick () {
      this.$refs.form.validate((valid) => {
        if (valid) {
          this.isSaveAndNewLoading = true

          this.handleSubmit({ button: 'save_and_create' })
        } else {
          this.scrollToErrors()
        }
      })
    },
    normalizeResourceData (resource) {
      const data = {}

      this.columns.forEach((column) => {
        const value = resource[column.name]

        if (this.isJsonColumn(column)) {
          data[column.name] = JSON.stringify(value || {}, null, '  ')
        } else if (value && typeof value === 'object') {
          data[column.name] = JSON.parse(JSON.stringify(value))
        } else {
          data[column.name] = value
        }
      })

      return data
    },
    async handleSubmit (eventData = {}) {
      try {
        await this.apiRequest

        this.$emit('success', eventData)
      } catch (error) {
        if (error.response?.data?.errors) {
          this.$refs.form.setErrors(error.response.data.errors)
        } else if (error.message) {
          this.$refs.form.setErrors([error.message])
        }

        this.scrollToErrors()
      } finally {
        this.isSaveAndNewLoading = false
        this.isSaveLoading = false

        if (eventData.button === 'save_and_create') {
          this.resourceData = this.normalizeResourceData(this.resource)
        }
      }
    }
  }
}
</script>

<style lang="scss" scoped>
@import 'utils/styles/variables';

form {
  @media screen and (max-width: $breakpoint-md) {
    min-height: calc(100% - 53px);
  }
}

.ivu-form-item {
  .ivu-form-item-label {
    order: 2;
  }
}
</style>
