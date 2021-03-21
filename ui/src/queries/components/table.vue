<template>
  <DataTable
    :style="{ height: 'calc(100% - 34px)' }"
    :data="paginatedData"
    :with-select="false"
    :with-sorting="false"
    :click-rows="false"
    :borderless="borderless"
    :compact="compact"
    :columns="normalizedColumns"
  />
  <div class="text-center border-top bg-white p-1">
    <Pagination
      :current="paginationParams.current"
      :total="total"
      :page-size="paginationParams.pageSize"
      :page-size-opts="pageSizeOpts"
      size="small"
      :show-sizer="!minimalPagination"
      :show-elevator="!minimalPagination"
      :show-total="true"
      @update:current="paginationParams.current = $event"
      @update:page-size="paginationParams.pageSize = $event"
    />
  </div>
</template>

<script>
import DataTable from 'data_tables/components/table'
import { modelNameMap } from 'utils/scripts/schema'

export default {
  name: 'QueryTable',
  components: {
    DataTable
  },
  props: {
    data: {
      type: Array,
      required: false,
      default: () => []
    },
    columns: {
      type: Array,
      required: false,
      default: () => []
    },
    borderless: {
      type: Boolean,
      required: false,
      default: false
    },
    compact: {
      type: Boolean,
      required: false,
      default: false
    },
    defaultPageSize: {
      type: Number,
      required: false,
      default: 100
    },
    minimalPagination: {
      type: Boolean,
      required: false,
      default: false
    }
  },
  data () {
    return {
      paginationParams: {
        current: 1,
        pageSize: this.defaultPageSize
      }
    }
  },
  computed: {
    total () {
      return this.data.length
    },
    pageSizeOpts () {
      return [20, 50, 100, 250, 500, 1000]
    },
    paginatedData () {
      const fromIndex = (this.paginationParams.current - 1) * this.paginationParams.pageSize

      return this.data.slice(fromIndex, fromIndex + this.paginationParams.pageSize)
    },
    normalizedColumns () {
      return this.columns.map((column, index) => {
        let reference
        const [, modelName] = column.name.match(/^(\w+)_id$/) || []

        if (modelName && modelNameMap[modelName]) {
          reference = { model_name: modelName }
        }

        return {
          key: index,
          title: column.name,
          type: column.column_type,
          reference
        }
      })
    }
  }
}
</script>
