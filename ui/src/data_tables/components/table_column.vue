<template>
  <td
    class="ivu-table-column"
  >
    <div class="ivu-table-cell">
      <DataCell
        v-if="column.reference?.model_name === 'active_storage/attachment'"
        :value="row[column.key]?.path"
        :type="'string'"
      />
      <Reference
        v-else-if="column.reference && row[column.key] && (!column.reference?.polymorphic || polymorphicModel)"
        :resource-id="referenceId"
        :reference-name="column.reference.model_name"
        :reference-data="row[column.reference.name]"
        :always-refer="alwaysRefer"
        :polymorphic-model="polymorphicModel"
      />
      <DataCell
        v-else
        :value="row[column.key]"
        :format="column.format"
        :type="column.type"
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
    alwaysRefer: {
      type: Boolean,
      required: false,
      default: false
    }
  },
  computed: {
    polymorphicModel () {
      if (this.column.reference?.polymorphic) {
        const polymorphicName = this.row[this.column.reference.name + '_type']

        return modelNameMap[underscore(polymorphicName).replace(/:{2}/g, '/')]
      } else {
        return null
      }
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
