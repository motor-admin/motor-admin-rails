<template>
  <div
    class="d-flex align-items-center info-cell position-relative"
    :class="isBottomControl && isEdit ? 'flex-column' : (!isEdit && isAssociationColumn ? 'flex-wrap' : 'flex-row')"
  >
    <Spin
      v-if="isLoading"
      fix
    />
    <VForm
      v-if="isEdit"
      ref="form"
      :model="resourceData"
      class="w-100"
      :rules="rules"
      label-position="top"
      @submit.prevent
    >
      <FormItem
        :prop="column.name"
        class="m-0"
      >
        <FormListInput
          v-if="column.is_array && !multipleValuesSelectorColumnTypes.includes(column.column_type)"
          v-model="resourceData[column.name]"
          :column="column"
        />
        <FormInput
          v-else
          v-model="resourceData[cellColumn.name]"
          :form-data="resource"
          :column="cellColumn"
          @enter="submit"
        />
      </FormItem>
    </VForm>
    <template v-else>
      <DataCell
        v-if="isActiveStorage"
        ref="dataCell"
        :value="value?.path"
        :text-truncate="false"
        :type="'string'"
      />
      <Reference
        v-else-if="column.reference && value && (!column.reference?.polymorphic || polymorphicModel)"
        ref="dataReference"
        :resource-id="referenceId"
        :reference-name="column.reference.model_name"
        :max-length="referenceSize"
        :show-popover="referencePopover"
        :reference-data="resource[column.reference.name]"
        :polymorphic-model="polymorphicModel"
      />
      <template
        v-else-if="column.column_type === 'association' && !isEmpty && associationColumnModel"
      >
        <Reference
          v-for="item in resource[column.format.association_name]"
          :key="item[associationColumnModel.primary_key]"
          :resource-id="item[associationColumnModel.primary_key]"
          :reference-name="associationColumnModel.name"
          :max-length="referenceSize"
          class="me-1 mb-1"
          :show-popover="false"
          :reference-data="item"
        />
      </template>
      <span
        v-else-if="isEmpty"
      > - </span>
      <DataCell
        v-else-if="column.column_type === 'currency'"
        ref="dataCell"
        :value="value"
        :format="{ ...column.format, currency: resource[`${column.name}_currency`] || resource['currency'] || column.format.currency }"
        :text-truncate="false"
        :type="columnType"
      />
      <DataCell
        v-else
        ref="dataCell"
        :value="value"
        :format="column.format"
        :text-truncate="false"
        :type="columnType"
      />
    </template>
    <div
      v-if="isEdit"
      class="d-inline-flex"
    >
      <VButton
        v-if="isBottomControl"
        icon="md-close"
        type="text"
        @click="toggleEdit"
      >
        {{ i18n.cancel }}
      </VButton>
      <VButton
        v-else
        icon="md-close"
        type="text"
        @click="toggleEdit"
      />
      <VButton
        v-if="isBottomControl"
        icon="md-checkmark"
        type="text"
        @click="submit"
      >
        {{ i18n.submit }}
      </VButton>
      <VButton
        v-else
        icon="md-checkmark"
        type="text"
        @click="submit"
      />
    </div>
    <Icon
      v-else-if="isEditable"
      type="md-create"
      data-role="edit"
      class="cursor-pointer action-button"
      @click="toggleEdit"
    />
    <Icon
      v-if="!isEdit && !isEmpty && withClipboard"
      type="md-clipboard"
      data-role="copy"
      class="cursor-pointer action-button"
      @click="copyToClipboard"
    />
  </div>
</template>

<script>
import DataCell from 'data_cells/components/data_cell'
import FormInput from 'data_forms/components/input'
import Reference from 'data_cells/components/reference'
import FormListInput from 'data_forms/components/list_input'
import { modelNameMap } from 'data_resources/scripts/schema'
import { isJsonColumn, buildColumnValidator } from '../scripts/form_utils'
import { includeParams, fieldsParams } from '../scripts/query_utils'
import { underscore } from 'utils/scripts/string'
import singularize from 'inflected/src/singularize'
import api from 'api'

export default {
  name: 'InfoCell',
  components: {
    DataCell,
    FormInput,
    FormListInput,
    Reference
  },
  props: {
    column: {
      type: Object,
      required: true
    },
    resource: {
      type: Object,
      required: true
    },
    resourceName: {
      type: String,
      required: true
    },
    referencePopover: {
      type: Boolean,
      required: false,
      default: true
    },
    referenceSize: {
      type: Number,
      required: false,
      default: 30
    },
    isKanban: {
      type: Boolean,
      required: false,
      default: false
    },
    editable: {
      type: Boolean,
      required: false,
      default: false
    }
  },
  emits: ['update'],
  data () {
    return {
      isEdit: false,
      isLoading: false,
      resourceData: {}
    }
  },
  computed: {
    associationColumn () {
      const association = this.associationColumnAssociation
      const associationModel = this.associationColumnModel
      const idsColumnName = `${singularize(association.name)}_${associationModel.primary_key}s`

      return {
        name: idsColumnName,
        display_name: this.column.display_name,
        reference: {
          name: association.name,
          model_name: associationModel.name,
          primary_key: associationModel.primary_key
        },
        is_array: true
      }
    },
    isAssociationColumn () {
      return this.column.column_type === 'association'
    },
    cellColumn () {
      if (this.isAssociationColumn) {
        return this.associationColumn
      } else {
        return this.column
      }
    },
    withClipboard () {
      return !!navigator.clipboard
    },
    multipleValuesSelectorColumnTypes () {
      return ['string', 'integer', 'float', 'tag']
    },
    model () {
      return modelNameMap[this.resourceName]
    },
    rules () {
      return {
        [this.column.name]: buildColumnValidator(this.column, this.resource)
      }
    },
    requestData () {
      const data = { ...this.resourceData }

      if (this.isJsonColumn) {
        data[this.column.name] = JSON.parse(data[this.column.name])
      }

      if (this.isActiveStorage) {
        data[this.column.name.replace(/_attachment$/, '')] = data[this.column.name]

        delete data[this.column.name]
      }

      return {
        fields: fieldsParams(this.model),
        include: includeParams(this.model),
        data
      }
    },
    isRichtext () {
      return this.column.column_type === 'richtext'
    },
    isBottomControl () {
      return this.isRichtext || (this.isKanban && this.isActiveStorage)
    },
    isJsonColumn () {
      return isJsonColumn(this.column, this.resource)
    },
    value () {
      if (this.isAssociationColumn) {
        return this.resource[this.column.format.association_name]
      } else {
        return this.resource[this.column.name]
      }
    },
    isEditable () {
      return this.editable && (this.column.access_type === 'read_write' || this.isActiveStorage)
    },
    columnType () {
      return this.column.column_type
    },
    referenceId () {
      const referenceModel = modelNameMap[this.column.reference.model_name]

      if (referenceModel) {
        return this.value[referenceModel.primary_key] || this.value
      } else {
        return this.value
      }
    },
    polymorphicModel () {
      if (this.column.reference?.polymorphic) {
        const polymorphicName = this.resource[this.column.reference.name + '_type']

        return modelNameMap[underscore(polymorphicName).replace(/:{2}/g, '/')]
      } else {
        return null
      }
    },
    isActiveStorage () {
      return this.column.reference?.model_name === 'active_storage/attachment'
    },
    isEmpty () {
      return [null, undefined, ''].includes(this.value) || (Array.isArray(this.value) && !this.value.length)
    },
    associationColumnAssociation () {
      return this.model.associations.find((a) => a.name === this.column.format.association_name)
    },
    associationColumnModel () {
      return modelNameMap[this.associationColumnAssociation?.model_name]
    }
  },
  methods: {
    copyToClipboard () {
      let promise

      if (this.$refs.dataCell) {
        promise = this.$refs.dataCell.$refs.cell.copyToClipboard()
      } else if (this.$refs.dataReference) {
        promise = this.$refs.dataReference.copyToClipboard()
      } else if (this.column.column_type === 'association') {
        const text = this.resource[this.column.format.association_name].map((item) => item[this.associationColumnModel.display_column]).join(', ')

        promise = navigator.clipboard.writeText(text)
      }

      promise.then(() => {
        this.$Message.info(this.i18n.copied_to_the_clipboard)
      })
    },
    toggleEdit () {
      if (!this.isEdit) {
        this.assignResourceData()
      }

      this.isEdit = !this.isEdit
    },
    assignResourceData () {
      if (this.isAssociationColumn) {
        this.resourceData[this.cellColumn.name] = this.value.map((item) => item[this.associationColumn.reference.primary_key])
      } else if (this.isJsonColumn) {
        this.resourceData[this.column.name] = JSON.stringify(this.value || {}, null, '  ')
      } else if (this.value && typeof this.value === 'object') {
        this.resourceData[this.column.name] = JSON.parse(JSON.stringify(this.value))
      } else {
        this.resourceData[this.column.name] = this.value
      }
    },
    async handleSubmit () {
      try {
        this.isLoading = true

        const result = await api.put(`data/${this.model.slug}/${this.resource[this.model.primary_key]}`, this.requestData)

        this.isEdit = false

        this.$emit('update', result.data.data)
        this.$Message.info(`${this.column.display_name} ${this.i18n.has_been_updated}`)
      } catch (error) {
        if (error.response?.data?.errors) {
          if (typeof error.response.data.errors[0] === 'string') {
            this.$refs.form.setErrors({ [this.column.name]: error.response.data.errors })
          } else {
            this.$refs.form.setErrors(error.response.data.errors)
          }
        } else if (error.message) {
          this.$refs.form.setErrors({ [this.column.name]: error.message })
        }
      } finally {
        this.isLoading = false
      }
    },
    submit () {
      this.$refs.form.validate((valid) => {
        if (valid) {
          this.handleSubmit()
        }
      })
    }
  }
}
</script>

<style lang="scss" scoped>
@import 'utils/styles/variables';

.info-cell {
  .action-button {
    opacity: 0;
    margin-left: 5px;
    line-height: unset;
    transition: color 0.2s ease;

    &:hover {
      color: mix(white, $primary-color, 20%)
    }
  }

  &:hover {
    .action-button {
      opacity: 1;
    }
  }

  :deep(.ivu-form-item-error-tip) {
    white-space: nowrap;
    text-overflow: ellipsis;
    width: 100%;
    overflow: hidden
  }
}
</style>
