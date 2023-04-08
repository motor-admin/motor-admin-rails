<template>
  <td
    class="ivu-table-column"
  >
    <div class="ivu-table-cell">
      <DataCell
        v-if="column.key !== 'id' && column.reference?.model_name === 'active_storage/attachment'"
        :value="row[column.key]?.path"
        :type="'string'"
      />
      <Reference
        v-else-if="column.reference && row[column.key] && (!column.reference?.polymorphic || polymorphicModel)"
        :resource-id="referenceId"
        :reference-name="column.reference.model_name"
        :reference-data="row[column.reference.name]"
        :always-refer="alwaysRefer"
        :show-popover="true"
        :polymorphic-model="polymorphicModel"
      />
      <template
        v-else-if="column.type === 'association'"
      >
        <Reference
          v-for="item in row[column.format.association_name]"
          :key="item[associationColumnModel.primary_key]"
          :resource-id="item[associationColumnModel.primary_key]"
          :reference-name="associationColumnModel.name"
          class="me-1 mb-1"
          :show-popover="true"
          :reference-data="item"
        />
      </template>
      <DataCell
        v-else-if="withHtml && column.type === 'string' && row[column.key]?.match(/^\<.*\>$/)"
        :value="row[column.key]"
        :type="'richtext'"
        :text-truncate="false"
        @click.stop
      />
      <DataCell
        v-else-if="column.type === 'currency'"
        :value="row[column.key]"
        :format="{ ...column.format, currency: row[`${column.key}_currency`] || row['currency'] || column.format.currency }"
        :type="column.type"
      />
      <DataCell
        v-else
        :value="row[column.key]"
        :format="column.format"
        :is-table="true"
        :type="column.type"
        @tag-click="$emit('tag-click', { key: column.key, value: $event })"
      />
    </div>
  </td>
</template>

<script>
import DataCell from 'data_cells/components/data_cell'
import Reference from 'data_cells/components/reference'
import { modelNameMap } from 'data_resources/scripts/schema'
import { underscore } from 'utils/scripts/string'

export default {
  name: 'TableColumn',
  components: {
    Reference,
    DataCell
  },
  props: {
    row: {
      type: [Object, Array],
      required: true
    },
    column: {
      type: Object,
      required: true
    },
    withHtml: {
      type: Boolean,
      required: false,
      default: false
    },
    alwaysRefer: {
      type: Boolean,
      required: false,
      default: false
    }
  },
  emits: ['tag-click'],
  computed: {
    polymorphicModel () {
      if (this.column.reference?.polymorphic) {
        const polymorphicName = this.row[this.column.reference.name + '_type']

        return modelNameMap[underscore(polymorphicName).replace(/:{2}/g, '/')]
      } else {
        return null
      }
    },
    associationColumnModel () {
      return modelNameMap[this.column.format.association_model_name]
    },
    referenceId () {
      const referenceModel = modelNameMap[this.column.reference.model_name]

      if (referenceModel) {
        return this.row[this.column.key][referenceModel.primary_key] || this.row[this.column.key]
      } else {
        return this.row[this.column.key]
      }
    }
  }
}
</script>
