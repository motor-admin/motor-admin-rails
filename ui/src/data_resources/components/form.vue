<template>
  <VForm
    ref="form"
    :model="resourceData"
    :rules="rules"
    :data-form-edited="isEdited"
    label-position="top"
    @submit="handleSubmit"
  >
    <Spin
      v-if="isLoading"
      fix
    />
    <FormItem
      v-for="column in columns"
      :key="column.name"
      :label="column.display_name"
      :prop="column.name"
    >
      <template #label>
        {{ column.display_name }}
        <i
          v-if="column.description"
          v-popover="
            {
              content: column.description,
              trigger: 'mouseenter',
              placement: 'left-end',
              bodyStyle: {
                maxWidth: '350px',
                overflowY: 'auto',
                maxHeight: '200px',
                whiteSpace: 'pre-wrap',
                lineBreak: 'anywhere'
              }
            }
          "
          class="ion ion-md-information-circle me-1 cursor-pointer"
        />
      </template>
      <FormListInput
        v-if="column.is_array && !multipleValuesSelectorColumnTypes.includes(column.column_type)"
        v-model="resourceData[column.name]"
        :column="column"
        @update:model-value="isEdited = true"
      />
      <FormInput
        v-else-if="isAssociationColumn(column)"
        v-model="resourceData[associationColumn(column).name]"
        :column="associationColumn(column)"
        :form-data="resource"
        @update:model-value="isEdited = true"
      />
      <FormInput
        v-else
        v-model="resourceData[column.name]"
        :column="column"
        :form-data="resource"
        @update:model-value="isEdited = true"
      />
    </FormItem>
  </VForm>
  <div class="sticky-footer">
    <VButton
      style="float: left"
      @click.stop="$emit('close')"
    >
      {{ i18n['cancel'] }}
    </VButton>
    <VButton
      v-if="withSaveAndCreateNew && action === 'new'"
      type="primary"
      ghost
      class="bg-white me-2"
      :loading="isSaveAndNewLoading"
      @click.stop="onSaveAndCreateClick"
    >
      {{ i18n['save_and_create_new'] }}
    </VButton>
    <VButton
      type="primary"
      :loading="isSaveLoading"
      @click.stop="onSaveClick"
    >
      {{ i18n['save'] }}
    </VButton>
  </div>
</template>

<script>
import api from 'api'
import { modelNameMap } from '../scripts/schema'
import { isJsonColumn, buildColumnValidator } from '../scripts/form_utils'
import { scrollToErrors } from 'data_forms/scripts/form_utils'
import { includeParams, fieldsParams } from '../scripts/query_utils'
import singularize from 'inflected/src/singularize'

import FormInput from 'data_forms/components/input'
import FormListInput from 'data_forms/components/list_input'

export default {
  name: 'ResourceForm',
  components: {
    FormInput,
    FormListInput
  },
  provide () {
    return {
      formComponent: this
    }
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
    withSaveAndCreateNew: {
      type: Boolean,
      required: false,
      default: true
    },
    resourceName: {
      type: String,
      required: true
    },
    parentResourceName: {
      type: String,
      required: false,
      default: null
    },
    parentResourceId: {
      type: [Number, String],
      required: false,
      default: null
    },
    associationName: {
      type: String,
      required: false,
      default: null
    }
  },
  emits: ['close', 'success'],
  data () {
    return {
      isLoading: false,
      isEdited: false,
      isSaveAndNewLoading: false,
      isSaveLoading: false,
      resourceData: {}
    }
  },
  computed: {
    multipleValuesSelectorColumnTypes () {
      return ['string', 'integer', 'float', 'tag']
    },
    rules () {
      return this.columns.reduce((acc, column) => {
        acc[column.name] = buildColumnValidator(column, this.resource)

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
        if (isJsonColumn(column, this.resource)) {
          data[column.name] = JSON.parse(data[column.name])
        }

        if (this.action === 'edit' && ((this.resource[column.name] ?? '') === data[column.name] || JSON.stringify(this.resource[column.name]) === JSON.stringify(data[column.name]))) {
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
      } else if (this.action === 'new' && this.parentResourceName) {
        const parentModel = modelNameMap[this.parentResourceName]
        const associationModelName = parentModel.associations.find((assoc) => assoc.name === this.associationName).model_name

        if (associationModelName === 'active_storage/attachment') {
          return api.post('data/active_storage__attachments', this.requestParams)
        } else {
          return api.post(`data/${parentModel.slug}/${this.parentResourceId}/${this.associationName}`, this.requestParams)
        }
      } else if (this.action === 'new') {
        return api.post(`data/${this.model.slug}`, this.requestParams)
      } else {
        return null
      }
    },
    hasNewEditColumnsToLoad () {
      const readColumnNames = this.model.columns.filter((column) => {
        return ['read_write', 'read_only'].includes(column.access_type)
      }).map((c) => c.name)

      return this.columns.some((c) => !readColumnNames.includes(c.name))
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

    if (this.action === 'edit' && this.hasNewEditColumnsToLoad) {
      this.loadData()
    }
  },
  methods: {
    scrollToErrors,
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
    associationColumn (column) {
      const association = this.model.associations.find((a) => a.name === column.format.association_name)
      const associationModel = modelNameMap[association.model_name]
      const idsColumnName = `${singularize(association.name)}_${associationModel.primary_key}s`

      return {
        name: idsColumnName,
        display_name: column.display_name,
        reference: {
          name: association.name,
          model_name: associationModel.name,
          primary_key: associationModel.primary_key
        },
        is_array: true
      }
    },
    isAssociationColumn (column) {
      return column.column_type === 'association'
    },
    normalizeResourceData (resource) {
      const data = {}

      this.columns.forEach((column) => {
        const value = resource[column.name]

        if (this.isAssociationColumn(column)) {
          const cellColumn = this.associationColumn(column)
          data[cellColumn.name] = value.map((item) => item[cellColumn.reference.primary_key])
        } else if (isJsonColumn(column, this.resource)) {
          data[column.name] = JSON.stringify(value ?? {}, null, '  ')
        } else if (value && typeof value === 'object') {
          data[column.name] = JSON.parse(JSON.stringify(value))
        } else {
          data[column.name] = value
        }
      })

      return data
    },
    loadData () {
      this.isLoading = true

      const accessTypes = ['read_only', 'read_write', 'write_only']

      return api.get(`data/${this.model.slug}/${this.resource[this.model.primary_key]}`, {
        params: {
          fields: fieldsParams(this.model, accessTypes),
          include: includeParams(this.model, accessTypes)
        }
      }).then((result) => {
        this.resourceData = this.normalizeResourceData(result.data.data)
      }).catch((error) => {
        if (error.response?.data?.errors) {
          this.$Message.error(error.response.data.errors.join('\n'))
        } else {
          this.$Message.error(error.message)
        }
      }).finally(() => {
        this.isLoading = false
      })
    },
    async handleSubmit (eventData = {}) {
      try {
        const result = await this.apiRequest

        this.$emit('success', result)

        if (eventData.button === 'save_and_create') {
          this.resourceData = this.normalizeResourceData(this.resource)
        } else {
          this.$emit('close')
        }
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
