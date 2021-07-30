<template>
  <div
    ref="wrapper"
    class="table-wrapper"
    :style="{ overflowX: 'auto', overflowY: compact ? 'hidden' : 'auto', height: '100%' }"
  >
    <table
      cellspacing="0"
      cellpadding="0"
      border="0"
      class="ivu-table ivu-table-default"
      :class="{ 'ivu-table-clickable-rows': clickRows, 'ivu-table-borderless': borderless, 'ivu-table-compact': compact }"
      style="position: relative"
    >
      <thead class="ivu-table-header">
        <tr>
          <th
            v-if="withSelect && columns.length"
            class="ivu-table-column ivu-table-column-center"
            :class="{ 'border-top' : !borderless && headerBorder }"
            :style="{ position: 'sticky', top: 0, left: 0, zIndex: 1 }"
          >
            <div class="ivu-table-cell ivu-table-cell-with-selection">
              <Checkbox
                :model-value="isSelectedAll"
                :disabled="data.length === 0"
                @on-change="toggleSelectAll"
              />
            </div>
          </th>
          <HeaderCell
            v-for="column in columns"
            :key="column.key"
            :sort-params="dataSort"
            :column="column"
            class="ivu-table-column"
            :with-sorting="withSorting"
            :class="{ 'border-top' : !borderless && headerBorder }"
            @update:sort-params="applySort"
          />
        </tr>
      </thead>
      <tbody
        v-if="data.length"
        class="ivu-table-tbody"
      >
        <Spin
          v-if="loading"
          fix
        />
        <tr
          v-for="(row, index) in data"
          :key="row.id || index"
          class="ivu-table-row"
          draggable="false"
          @click.prevent="onRowClick(row)"
        >
          <td
            v-if="withSelect"
            class="ivu-table-column ivu-table-column-center"
            :style="{ position: 'sticky', left: 0 }"
            @click.stop
          >
            <div class="ivu-table-cell ivu-table-cell-with-selection">
              <Checkbox v-model="row._selected" />
            </div>
          </td>
          <td
            v-for="column in columns"
            :key="column.key"
            class="ivu-table-column"
          >
            <div class="ivu-table-cell">
              <DataCell
                v-if="column.reference?.model_name === 'active_storage/attachment'"
                :value="row[column.key]?.path"
                :type="'string'"
              />
              <Reference
                v-else-if="column.reference && row[column.key]"
                :resource-id="getReferenceId(column, row)"
                :reference-name="column.reference.model_name"
                :reference-data="row[column.reference.name]"
                :always-refer="alwaysRefer"
                :polymorphic-name="column.reference?.polymorphic ? row[column.reference.name + '_type'] : null"
              />
              <DataCell
                v-else
                :value="row[column.key]"
                :format="column.format"
                :type="column.type"
              />
            </div>
          </td>
        </tr>
      </tbody>
    </table>
    <div
      v-if="data.length === 0"
      :style="{ margin: 'auto', height: columns.length ? 'calc(100% - 40px)' : '100%', display: 'flex', position: 'relative' }"
    >
      <Spin
        v-if="loading"
        fix
      />
      <div
        v-else
        style="margin: auto;"
      >
        {{ i18n['no_data'] }}
      </div>
    </div>
  </div>
</template>

<script>
import DataCell from 'data_cells/components/data_cell'
import Reference from 'data_cells/components/reference'
import HeaderCell from './header_cell'
import { modelNameMap } from 'data_resources/scripts/schema'

export default {
  name: 'DataTable',
  components: {
    DataCell,
    HeaderCell,
    Reference
  },
  props: {
    data: {
      type: Array,
      required: false,
      default: () => []
    },
    sortParams: {
      type: Object,
      required: false,
      default () {
        return {}
      }
    },
    columns: {
      type: Array,
      required: false,
      default: () => []
    },
    withSelect: {
      type: Boolean,
      required: false,
      default: true
    },
    alwaysRefer: {
      type: Boolean,
      required: false,
      default: false
    },
    clickRows: {
      type: Boolean,
      required: false,
      default: true
    },
    withSorting: {
      type: Boolean,
      required: false,
      default: true
    },
    borderless: {
      type: Boolean,
      required: false,
      default: false
    },
    headerBorder: {
      type: Boolean,
      required: false,
      default: true
    },
    scrollToTopOnDataUpdate: {
      type: Boolean,
      required: false,
      default: true
    },
    compact: {
      type: Boolean,
      required: false,
      default: false
    },
    loading: {
      type: Boolean,
      required: false,
      default: false
    }
  },
  emits: ['row-click', 'sort-change', 'update:sortParams'],
  data () {
    return {
      dataSort: {}
    }
  },
  computed: {
    isSelectedAll () {
      if (this.data.length === 0) {
        return false
      } else {
        return !this.data.find((row) => !row._selected)
      }
    }
  },
  watch: {
    sortParams (value) {
      this.dataSort = value
    },
    data () {
      if (this.scrollToTopOnDataUpdate) {
        this.scrollToTop()
      }
    }
  },
  mounted () {
    this.dataSort = this.sortParams
  },
  methods: {
    scrollToTop () {
      this.$refs.wrapper.scrollTop = 0
    },
    getReferenceId (column, row) {
      const referenceModel = modelNameMap[column.reference.model_name]

      if (referenceModel) {
        return row[column.key][referenceModel.primary_key] || row[column.key]
      } else {
        return row[column.key]
      }
    },
    onRowClick (row) {
      setTimeout(() => {
        if (window.getSelection().toString().length === 0) {
          this.$emit('row-click', row)
        }
      }, 0)
    },
    toggleSelectAll (value) {
      this.data.forEach((row) => {
        row._selected = value
      })
    },
    applySort (value) {
      this.dataSort = value

      this.$emit('update:sortParams', this.dataSort)
      this.$emit('sort-change', this.dataSort)
    }
  }
}
</script>

<style lang="scss">
.ivu-table {
  overflow: auto;
  width: 100%;
  height: auto;
}

.ivu-table-clickable-rows {
  .ivu-table-row {
    cursor: pointer;
  }
}

.ivu-table-cell {
  white-space: nowrap;
}

.ivu-table.ivu-table-borderless {
  th {
    background: #fff;
  }
}

.ivu-table.ivu-table-compact {
  overflow-y: hidden;

  .ivu-table-column {
    height: 32px;
    padding: 0;
  }

  .ivu-btn {
    line-height: 20px;
    height: 22px;
    padding: 0 10px;
  }
}

.ivu-table-cell-sort {
  user-select: none;
}

.table-wrapper::-webkit-scrollbar {
  width: 4px;
  border-top: 1px solid #dee2e6;
  height: 4px;
  z-index: 12;
}

.table-wrapper::-webkit-scrollbar-thumb {
  border-radius: 8px;
  box-shadow: none;
  border-top: 1px solid #dee2e6;
  background-color: #d3d3d3;
  background-clip: padding-box;
}
</style>
