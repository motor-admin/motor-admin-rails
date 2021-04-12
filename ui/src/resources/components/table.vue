<template>
  <div>
    <div
      class="row"
      :style="{ margin: '10px 0' }"
    >
      <div class="col-6 d-flex align-items-center">
        <b
          v-if="withTitle && !selectedRows.length"
          class="h4 nowrap"
        >{{ title }}</b>
        <ResourceActions
          v-if="selectedRows.length"
          :resources="selectedRows"
          :with-deselect="true"
          :resource-name="model.name"
          :label="`Actions (${selectedRows.length})`"
          @start-action="isLoading = true"
          @finish-action="loadData"
        />
      </div>
      <div class="col-6 d-flex justify-content-end">
        <ResourceSearch
          v-model="searchQuery"
          style="max-width: 400px"
          class="mx-1"
          :placeholder="`Search ${(associationModel?.display_name || model.display_name).toLowerCase()}...`"
          @search="loadData"
        />
        <VButton
          type="default"
          icon="ios-funnel"
          class="mx-1"
        />
        <NewResourceButton
          class="mx-1"
          :resource-name="model.name"
          :parent-resource="associationParams ? { name: resourceName, id: associationParams.id } : null"
          @success="loadData"
        />
      </div>
    </div>
    <template v-if="!isReloading">
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
      v-if="isReloading"
      :style="{ height: height, paddingBottom: '1px', position: 'relative' }"
    >
      <Spin
        fix
      />
    </div>
  </div>
</template>

<script>
import api from 'api'
import { modelNameMap } from 'utils/scripts/schema'
import DataTable from 'data_tables/components/table'
import ResourceSearch from './search'
import ResourceActions from './actions'
import NewResourceButton from './new_button'

import { truncate } from 'utils/scripts/string'

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
    ResourceSearch,
    ResourceActions,
    NewResourceButton
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
    title () {
      return truncate(this.associationModel?.display_name || this.model.display_name, 60)
    },
    selectedRows () {
      return this.rows.filter((row) => row._selected)
    },
    queryPath () {
      if (this.associationParams) {
        return [
          'data',
          modelNameMap[this.resourceName].slug,
          this.associationParams.id,
          this.associationParams.name
        ].join('/')
      } else {
        return `data/${this.model.slug}`
      }
    },
    queryParams () {
      const params = {
        meta: 'count',
        fields: {
          [this.model.name]: this.columns.map((e) => e.key)
        },
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
      return this.model.columns.map((column) => {
        return column.reference?.name
      }).filter(Boolean).join(',')
    },
    associationModel () {
      if (this.associationParams?.name) {
        return modelNameMap[this.resourceName].associations.find((assoc) => {
          return assoc.slug === this.associationParams.name
        })
      } else {
        return null
      }
    },
    model () {
      if (this.associationModel) {
        const assocSchemaName = this.associationModel.model_name

        return modelNameMap[assocSchemaName]
      } else {
        return modelNameMap[this.resourceName]
      }
    },
    columns () {
      return this.model.columns.map((column) => {
        const type = column.validators.find((v) => v.includes?.length) ? DataTypes.TAG : column.column_type

        if (column.reference?.name !== modelNameMap[this.resourceName].name &&
            ['read_only', 'read_write'].includes(column.access_type)) {
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
    columns: {
      deep: true,
      handler (newValue, oldValue) {
        if (newValue.length > oldValue.length) {
          this.loadData()
        }
      }
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
