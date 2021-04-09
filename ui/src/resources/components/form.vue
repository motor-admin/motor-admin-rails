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
      <FormInput
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
      @click.stop="onIsSaveAndCreateClick"
    >
      Save and Create New
    </VButton>
    <VButton
      type="primary"
      :loading="isSaveLoading"
      @click.stop="onIsSaveClick"
    >
      Save
    </VButton>
  </div>
</template>

<script>
import api from 'api'
import { modelNameMap } from 'utils/scripts/schema'

import Validators from 'utils/scripts/validators'
import FormInput from 'data_forms/components/input'

const TIMESTAMP_COLUMN_NAMES = ['deleted_at', 'inserted_at', 'created_at', 'updated_at']

export default {
  name: 'ResourceForm',
  components: {
    FormInput
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
        if (column.reference) {
          acc[column.name] = { required: true }

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
          acc[column.name].unshift({ type: 'email' })
        }

        if (['integer', 'bigint', 'int', 'float', 'demical', 'double'].includes(column.column_type)) {
          acc[column.name].unshift({ type: 'number' })
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
        if (['json', 'jsonb'].includes(column.column_type)) {
          data[column.name] = JSON.parse(data[column.name])
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
      return this.model.columns.filter((column) => {
        return (
          this.model.primary_key !== column.name &&
          !TIMESTAMP_COLUMN_NAMES.includes(column.name)
        )
      })
    }
  },
  created () {
    this.resourceData = this.normalizeResourceData(this.resource)
  },
  methods: {
    onIsSaveClick () {
      this.$refs.form.validate((valid) => {
        if (valid) {
          this.isSaveLoading = true

          this.handleSubmit({ button: 'save' })
        }
      })
    },
    onIsSaveAndCreateClick () {
      this.$refs.form.validate((valid) => {
        if (valid) {
          this.isSaveAndNewLoading = true

          this.handleSubmit({ button: 'save_and_create' })
        }
      })
    },
    normalizeResourceData (resource) {
      const data = {}

      this.columns.forEach((column) => {
        const value = resource[column.name]
        if (['json', 'jsonb'].includes(column.column_type) || (value && typeof value === 'object')) {
          data[column.name] = JSON.stringify(value || {}, null, '  ')
        } else {
          data[column.name] = resource[column.name]
        }
      })

      return data
    },
    handleSubmit (eventData = {}) {
      this.apiRequest.then((result) => {
        this.$emit('success', eventData)
      }).catch((error) => {
        console.error(error)
      }).finally(() => {
        this.isSaveAndNewLoading = false
        this.isSaveLoading = false

        if (eventData.button === 'save_and_create') {
          this.resourceData = this.normalizeResourceData(this.resource)
        }
      })
    }
  }
}
</script>

<style lang="scss" scoped>
form {
  min-height: calc(100% - 53px);
}

.drawer-footer {
  width: 100%;
  position: sticky;
  bottom: 0;
  left: 0;
  border-top: 1px solid #e8e8e8;
  padding: 10px 0px;
  text-align: right;
  background: #fff;
}

.ivu-form-item {
  .ivu-form-item-label {
    order: 2;
  }
}
</style>
