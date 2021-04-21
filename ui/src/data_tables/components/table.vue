<template>
  <div
    ref="wrapper"
    class="table-wrapper"
    :style="{ overflow: 'auto', height: '100%' }"
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
          <th
            v-for="column in columns"
            :key="column.key"
            class="ivu-table-column"
            :class="{ 'border-top' : !borderless && headerBorder }"
            :style="{ position: 'sticky', top: 0 }"
          >
            <div class="ivu-table-cell">
              <span
                :class="{ 'ivu-table-cell-sort': withSorting }"
                @click.prevent="toggleSort(column.key)"
              >{{ column.title }}</span>
              {{ ' ' }}
              <span
                v-if="withSorting"
                class="ivu-table-sort"
              >
                <i
                  class="ion ion-md-arrow-dropup"
                  :class="{ on: dataSort.key === column.key && dataSort.order === 'asc' }"
                  @click.prevent="applySort({ key: column.key, order: 'asc' })"
                />
                <i
                  class="ion ion-md-arrow-dropdown"
                  :class="{ on: dataSort.key === column.key && dataSort.order === 'desc' }"
                  @click.prevent="applySort({ key: column.key, order: 'desc' })"
                />
              </span>
            </div>
          </th>
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
              <Reference
                v-if="column.reference && row[column.key]"
                :resource-id="row[column.key]"
                :show-popover="!!column.reference.polymorphic"
                :reference-name="column.reference.model_name"
                :reference-data="row[column.reference.name]"
                :polymorphic-name="row[column.reference.name + '_type']"
              />
              <DataCell
                v-else
                :value="row[column.key]"
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
      <div style="margin: auto;">
        No Data
      </div>
    </div>
  </div>
</template>

<script>
import DataCell from 'data_cells/components/data_cell'
import Reference from 'data_cells/components/reference'

export default {
  name: 'DataTable',
  components: {
    DataCell,
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
      this.$refs.wrapper.scrollTop = 0
    }
  },
  mounted () {
    this.dataSort = this.sortParams
  },
  methods: {
    onRowClick (row) {
      setTimeout(() => {
        if (window.getSelection().toString().length === 0) {
          this.$emit('row-click', row)
        }
      }, 0)
    },
    toggleSort (key) {
      if (this.dataSort.key === key) {
        if (this.dataSort.order === '') {
          this.applySort({ key: key, order: 'asc' })
        } else if (this.dataSort.order === 'asc') {
          this.applySort({ key: key, order: 'desc' })
        } else if (this.dataSort.order === 'desc') {
          this.applySort({})
        }
      } else {
        this.applySort({ key: key, order: 'asc' })
      }
    },
    toggleSelectAll (value) {
      this.data.forEach((row) => {
        row._selected = value
      })
    },
    applySort (value) {
      if (value.key === this.dataSort.key && value.order === this.dataSort.order) {
        this.dataSort = {}
      } else {
        this.dataSort = value
      }

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
  .ivu-table-column {
    height: 32px;
  }

  .ivu-btn {
    line-height: 20px;
    padding-top: 0.1px;
    height: 22px;
  }
}

.ivu-table-cell-sort {
  -webkit-touch-callout: none;
  -webkit-user-select: none;
  -khtml-user-select: none;
  -moz-user-select: none;
  -ms-user-select: none;
  user-select: none;
}
</style>
