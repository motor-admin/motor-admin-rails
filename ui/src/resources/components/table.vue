<template>
  <template
    v-if="!isReloading"
  >
    <DataTable
      :data="rows"
      :loading="isLoading"
      :columns="columns"
      :style="{ height: height, paddingBottom: '1px' }"
      @sort-change="applySort"
      @row-click="onRowClick"
    />
    <div class="text-center border-top bg-white p-1">
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
  </template>
  <div
    v-else
    :style="{ height: height, paddingBottom: '1px' }"
  >
    <Spin
      fix
    />
  </div>
</template>

<script>
import api from 'api'
import store from 'store'
import DataTable from 'data_tables/components/table'

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
  components: {
    DataTable
  },
  props: {
    resourceName: {
      type: String,
      required: true
    },
    height: {
      type: String,
      required: false,
      default: '500px'
    },
    associationParams: {
      type: Object,
      require: false,
      default: null
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
    queryPath () {
      if (this.associationParams) {
        return [
          'data',
          this.resourceName,
          this.associationParams.id,
          this.associationParams.name
        ].join('/')
      } else {
        return `data/${this.resourceName}`
      }
    },
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
        ...cols
      ]
    }
  },
  watch: {
    resourceName () {
      this.reset()
    },
    associationParams () {
      this.loadData()
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
    onRowClick (value) {
      this.$router.push({
        name: 'resources',
        params: {
          fragments: [...this.$route.params.fragments, value.id]
        }
      })
    },
    loadData () {
      this.isLoading = true

      api.get(this.queryPath, {
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
