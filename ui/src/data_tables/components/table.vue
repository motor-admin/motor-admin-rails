<template>
  <div
    class="table-wrapper"
    :style="{ overflow: 'auto', opacity: loading ? 0.8 : 1 }"
  >
    <table
      cellspacing="0"
      cellpadding="0"
      border="0"
      class="ivu-table ivu-table-default"
    >
      <thead class="ivu-table-header">
        <tr>
          <th
            class="ivu-table-column ivu-table-column-center"
            :style="{ position: 'sticky', top: 0, left: 0, zIndex: 1 }"
          >
            <div class="ivu-table-cell ivu-table-cell-with-selection">
              <Checkbox
                :model-value="isSelectedAll"
                :disabled="data.length === 0"
                @on-change="toggleAll"
              />
            </div>
          </th>
          <th
            v-for="column in columns"
            :key="column.key"
            class="ivu-table-column"
            :style="{ position: 'sticky', top: 0 }"
          >
            <div class="ivu-table-cell nowrap">
              <span class="ivu-table-cell-sort">{{ column.title }}</span>
              {{ ' ' }}
              <span class="ivu-table-sort">
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
        <tr
          v-for="(row, index) in data"
          :key="index"
          class="ivu-table-row"
          draggable="false"
          @click.stop="$emit('row-click', row)"
        >
          <td
            class="ivu-table-column ivu-table-column-center"
            :style="{ position: 'sticky', left: 0 }"
            @click.stop
          >
            <div class="ivu-table-cell nowrap ivu-table-cell-with-selection">
              <Checkbox v-model="row._selected" />
            </div>
          </td>
          <td
            v-for="column in columns"
            :key="column.key"
            class="ivu-table-column"
          >
            <div class="ivu-table-cell">
              <span>{{ row[column.key] }}</span>
            </div>
          </td>
        </tr>
      </tbody>
    </table>
    <div
      v-if="data.length === 0"
      style="margin: auto; height: calc(100% - 40px); display: flex;"
    >
      <div style="margin: auto;">
        No Data
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'DataTable',
  props: {
    data: {
      type: Array,
      required: false,
      default: () => []
    },
    sortParams: {
      type: Object,
      required: false,
      default: () => {}
    },
    columns: {
      type: Array,
      required: true
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
      this.sortData = value
    }
  },
  methods: {
    toggleAll (value) {
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

.ivu-table-header {
  .ivu-table-column {
    border-top: 1px solid #e8eaec;
  }
}

.ivu-table-row {
  cursor: pointer;
}

.ivu-table-cell {
  white-space: nowrap;
}
</style>
