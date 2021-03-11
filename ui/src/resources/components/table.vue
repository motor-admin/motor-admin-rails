<template>
  <template
    v-if="!isReloading"
  >
    <div
      class="row"
      :style="{ margin: '10px 0' }"
    >
      <div class="col-4 d-flex align-items-center">
        <b
          v-if="withTitle"
          class="h4"
        >{{ associationSchema?.display_name || resourceSchema.display_name }}</b>
      </div>
      <div class="col-8 d-flex justify-content-end">
        <ResourceSearch
          v-model="searchQuery"
          style="max-width: 400px"
          class="mx-1"
          :placeholder="`Search ${(associationSchema?.display_name || resourceSchema.display_name).toLowerCase()}...`"
          @search="loadData"
        />
        <VButton
          type="default"
          icon="ios-funnel"
          class="mx-1"
        />
        <VButton
          type="success"
          icon="md-add"
          class="mx-1"
        />
      </div>
    </div>
    <DataTable
      :data="rows"
      :loading="isLoading"
      :columns="columns"
      :style="{ height: height, paddingBottom: '1px' }"
      :sort-params="sortParams"
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
    :style="{ height: height, paddingBottom: '1px', position: 'relative' }"
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
import ResourceSearch from './search'

import DataTypes from 'data_cells/scripts/data_types'

const defaultPaginationParams = {
  current: 1,
  pageSize: 20,
  total: 0,
  pageSizeOpts: [20, 50, 100, 250, 500]
}

const defaultSortParams = {
  order: 'desc',
  key: 'id'
}

export default {
  name: 'ResourceTable',
  components: {
    DataTable,
    ResourceSearch
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
    withTitle: {
      type: Boolean,
      required: false,
      default: false
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
      sortParams: { ...defaultSortParams },
      searchQuery: '',
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

      if (this.includeParams) {
        params.include = this.includeParams
      }

      if (this.searchQuery) {
        params.q = this.searchQuery
      }

      return params
    },
    includeParams () {
      return this.resourceSchema.columns.map((column) => {
        return column.reference?.name
      }).filter(Boolean).join(',')
    },
    associationSchema () {
      if (this.associationParams?.name) {
        return store.getters.slugsMap[this.resourceName].associations.find((assoc) => {
          return assoc.slug === this.associationParams.name
        })
      } else {
        return null
      }
    },
    resourceSchema () {
      if (this.associationSchema) {
        const assocSchemaName = this.associationSchema.schema_name

        return store.getters.namesMap[assocSchemaName]
      } else {
        return store.getters.slugsMap[this.resourceName]
      }
    },
    columns () {
      return this.resourceSchema.columns.map((column) => {
        const type = column.validators.find((v) => v.includes?.length) ? DataTypes.TAG : column.column_type

        if (column.reference?.name !== store.getters.slugsMap[this.resourceName].name) {
          return {
            key: column.name,
            title: column.display_name,
            reference: column.reference,
            type
          }
        } else {
          return null
        }
      }).filter(Boolean)
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
      this.sortParams = { ...defaultSortParams }
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
