<template>
  <th
    class="ivu-table-column"
  >
    <div class="ivu-table-cell">
      <i
        v-if="column.description"
        v-popover="popoverParams"
        class="ion ion-md-information-circle me-1 cursor-pointer"
      />
      <span
        :class="{ 'ivu-table-cell-sort': withSorting }"
        @click.prevent="toggleSort"
      >{{ column.title }}</span>
      {{ ' ' }}
      <span
        v-if="withSorting && column.sortable !== false"
        class="ivu-table-sort"
      >
        <i
          class="ion ion-md-arrow-dropup"
          :class="{ on: sortParams.key === sortKey && sortParams.order === 'asc' }"
          @click.prevent="applySort('asc')"
        />
        <i
          class="ion ion-md-arrow-dropdown"
          :class="{ on: sortParams.key === sortKey && sortParams.order === 'desc' }"
          @click.prevent="applySort('desc')"
        />
      </span>
    </div>
  </th>
</template>

<script>
import { modelNameMap } from 'data_resources/scripts/schema'

export default {
  name: 'DataTableHeaderCell',
  props: {
    column: {
      type: Object,
      required: true
    },
    sortParams: {
      type: Object,
      required: true
    },
    withSorting: {
      type: Boolean,
      required: true
    }
  },
  emits: ['update:sortParams'],
  computed: {
    popoverParams () {
      return {
        content: this.column.description,
        trigger: 'mouseenter',
        bodyStyle: {
          maxWidth: '350px',
          overflowY: 'auto',
          maxHeight: '200px',
          whiteSpace: 'pre-wrap',
          lineBreak: 'anywhere'
        }
      }
    },
    sortKey () {
      if (this.column.reference?.reference_type === 'has_one') {
        const referenceModel = modelNameMap[this.column.reference.model_name]

        if (referenceModel) {
          return `${this.column.key}.${referenceModel.primary_key}`
        } else {
          return this.column.key
        }
      } else {
        return this.column.key
      }
    }
  },
  methods: {
    applySort (order) {
      if (!order || (this.sortKey === this.sortParams.key && order === this.sortParams.order)) {
        this.$emit('update:sortParams', {})
      } else {
        this.$emit('update:sortParams', { key: this.sortKey, order })
      }
    },
    toggleSort () {
      if (this.column.sortable !== false) {
        if (this.sortParams.key === this.sortKey) {
          if (this.sortParams.order === '') {
            this.applySort('asc')
          } else if (this.sortParams.order === 'asc') {
            this.applySort('desc')
          } else if (this.sortParams.order === 'desc') {
            this.applySort()
          }
        } else {
          this.applySort('asc')
        }
      }
    }
  }
}
</script>

<style lang="scss" scoped>
.ivu-table-column {
  position: sticky;
  top: 0
}
</style>
