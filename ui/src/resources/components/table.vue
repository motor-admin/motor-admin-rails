<template>
  <div
    v-if="!isReloading"
  >
    <VTable
      :fixed-height="'calc(100vh - 188px)'"
      :data="rows"
      :loading="isLoading"
      :columns="columns"
      @on-sort-change="applySort"
    />
    <div class="text-center bg-white p-1">
      <Pagination
        :current="paginationParams.current"
        :total="paginationParams.total"
        :page-size="paginationParams.pageSize"
        :page-size-opts="paginationParams.pageSizeOpts"
        size="small"
        show-sizer
        show-elevator
        show-total
        @update:current="paginationParams.current = $event"
        @update:page-size="paginationParams.pageSize = $event"
        @on-change="loadData"
        @on-page-size-change="loadData"
      />
    </div>
  </div>
  <Spin
    v-else
    fix
  />
</template>

<script>
import api from 'api'
import store from 'store'

import DateTimeCell from 'cells/components/date_time'
import JsonCell from 'cells/components/json'

const defaultPaginationParams = {
  current: 1,
  pageSize: 20,
  total: 0,
  pageSizeOpts: [20, 50, 75, 100]
}

export default {
  name: 'ResourceTable',
  props: {
    resourceName: {
      type: String,
      required: true
    }
  },
  data () {
    return {
      isLoading: true,
      isReloading: true,
      rows: [],
      sortParams: {},
      paginationParams: { ...defaultPaginationParams }
    }
  },
  computed: {
    queryParams () {
      const params = {
        meta: 'count',
        page: {
          limit: this.paginationParams.pageSize,
          offset: this.paginationParams.pageSize * (this.paginationParams.current - 1)
        }
      }

      if (this.sortParams.key) {
        params.sort = `${this.sortParams.order === 'desc' ? '-' : ''}${this.sortParams.key}`
      }

      return params
    },
    resourceSchema () {
      return store.getters.slugsMap[this.resourceName]
    },
    columns () {
      const cols = this.resourceSchema.columns.map((column) => {
        const col = {
          key: column.name,
          title: column.display_name,
          width: 300,
          sortable: 'custom'
        }

        if (column.column_type === 'datetime') {
          col.width = 190
          col.render = (h, { row }) => {
            return h(DateTimeCell, { value: row[column.name] })
          }
        }

        if (['jsonb', 'json', 'hstore'].includes(column.column_type)) {
          col.render = (h, { row }) => {
            return h(JsonCell, { value: row[column.name] })
          }
        }

        return col
      })

      return [
        {
          type: 'selection',
          width: 60,
          align: 'center',
          fixed: 'left'
        },
        ...cols
      ]
    }
  },
  watch: {
    resourceName () {
      this.reset()
    }
  },
  mounted () {
    this.loadData()
  },
  methods: {
    reset () {
      this.sortParams = {}
      this.paginationParams = { ...defaultPaginationParams }
      this.isReloading = true
      this.loadData()
    },
    applySort (sort) {
      this.sortParams = sort

      this.loadData()
    },
    loadData () {
      this.isLoading = true

      api.get(`data/${this.resourceName}`, {
        params: this.queryParams
      }).then((result) => {
        this.rows = result.data.data
        this.paginationParams.total = result.data.meta.count
      }).finally(() => {
        this.$nextTick(() => {
          this.isLoading = false
          this.isReloading = false
        })
      })
    }
  }
}
</script>
