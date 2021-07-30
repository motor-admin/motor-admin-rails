<template>
  <div>
    <div
      class="row"
      :style="{ margin: '10px 0' }"
    >
      <div
        v-if="(withTitle && !widthLessThan('sm')) || selectedRows.length"
        class="col-6 d-flex align-items-center pe-0"
      >
        <VButton
          v-if="withMenu"
          icon="md-menu"
          size="small"
          type="dashed"
          class="me-2 bg-transparent align-bottom"
          @click="$emit('click-menu')"
        />
        <VButton
          v-if="withResize"
          icon="md-resize"
          size="small"
          type="dashed"
          class="me-2 bg-transparent d-none d-md-block"
          @click="$emit('click-resize')"
        />
        <SettingsMask
          v-if="isShowSettings"
          class="me-2"
          :settings-type="'actions'"
          :button-only="true"
          :resource="model"
        />
        <SettingsMask
          v-if="isShowSettings && !withResize"
          class="me-2"
          :settings-type="'scopes'"
          :button-only="true"
          :resource="model"
        />
        <span
          v-if="withTitle && !widthLessThan('sm') && !selectedRows.length"
          class="fs-4 fw-bold nowrap overflow-hidden text-truncate"
        >{{ title }}
          <template v-if="currentScope">
            ({{ currentScope.display_name }})
          </template>
        </span>
        <ResourceActions
          v-if="selectedRows.length && !isShowSettings"
          :resources="selectedRows"
          :with-deselect="true"
          :resource-name="model.name"
          :label="`${i18n['actions']} (${selectedRows.length})`"
          @start-action="isLoading = true"
          @finish-action="onFinishAction"
        />
      </div>
      <div
        class="d-flex justify-content-end"
        :class="(withTitle && !widthLessThan('sm')) || selectedRows.length ? 'col-6' : 'col-12'"
      >
        <ResourceSearch
          v-model="searchQuery"
          style="max-width: 470px"
          class="me-1"
          :placeholder="`${i18n['search']} ${(association?.display_name || model.display_name).toLowerCase()}...`"
          @search="applySearch"
        />
        <Badge
          :count="filtersCount"
          type="primary"
        >
          <VButton
            icon="ios-funnel"
            data-role="filter"
            class="mx-1 bg-white"
            @click="openFiltersModal"
          />
        </Badge>
        <NewResourceButton
          class="ms-1"
          :model="model"
          :association="association"
          :parent-resource="associationParams ? { name: resourceName, id: associationParams.id } : null"
          @success="loadDataAndCount"
        />
      </div>
    </div>
    <div
      v-if="!isReloading"
      class="position-relative"
    >
      <SettingsMask
        v-if="isShowSettings"
        :settings-type="'columns'"
        :resource="model"
      />
      <Spin
        v-if="isLoading"
        fix
      />
      <DataTable
        ref="table"
        :data="rows"
        :columns="columns"
        :style="{ height: height }"
        :sort-params="sortParams"
        :scroll-to-top-on-data-update="false"
        :click-rows="!!model.primary_key"
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
          @on-change="onPageChange"
          @on-page-size-change="onPageSizeChange"
        />
      </div>
    </div>
    <div
      v-else
      :style="{ height: height.replace(/\)$/, ' + 34px)'), paddingBottom: '1px', position: 'relative' }"
    >
      <Spin
        fix
      />
    </div>
  </div>
</template>

<script>
import api from 'api'
import { reactive } from 'vue'
import { modelNameMap } from '../scripts/schema'
import DataTable from 'data_tables/components/table'
import ResourceSearch from './search'
import ResourceActions from './actions'
import NewResourceButton from './new_button'
import FiltersModal from './filters_modal'

import { widthLessThan } from 'utils/scripts/dimensions'
import { truncate } from 'utils/scripts/string'
import { includeParams, fieldsParams } from '../scripts/query_utils'

import { isShowSettings } from 'settings/scripts/toggle'
import SettingsMask from 'settings/components/mask'
import throttle from 'view3/src/utils/throttle'

const defaultPaginationParams = {
  current: 1,
  pageSize: 20,
  total: 0,
  pageSizeOpts: [20, 50, 100, 250, 500]
}

const itemsCountCache = reactive({})

export default {
  name: 'ResourceTable',
  components: {
    DataTable,
    ResourceSearch,
    ResourceActions,
    NewResourceButton,
    SettingsMask
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
    withResize: {
      type: Boolean,
      required: false,
      default: false
    },
    withMenu: {
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
  emits: ['click-resize', 'click-menu', 'action-applied'],
  data () {
    return {
      isLoading: true,
      isReloading: true,
      rows: [],
      sortParams: { ...this.defaultSortParams },
      filterParams: [],
      searchQuery: '',
      paginationParams: { ...defaultPaginationParams }
    }
  },
  computed: {
    isShowSettings,
    defaultSortParams () {
      if (this.model.primary_key) {
        return {
          order: this.model.columns.find((c) => c.name === this.model.primary_key).column_type === 'integer' ? 'desc' : 'asc',
          key: this.model.primary_key
        }
      } else {
        return {}
      }
    },
    currentScope () {
      return this.model.scopes.find((scope) => scope.name === this.$route.query?.scope)
    },
    routeQueryParams () {
      const query = {}

      if (Object.keys(this.filterParams).length) {
        query.filter = this.filterParams
      }

      if (this.sortParams?.key &&
        (this.sortParams.key !== this.defaultSortParams.key ||
        this.sortParams.order !== this.defaultSortParams.order)) {
        query.sort = `${this.sortParams.order === 'desc' ? '-' : ''}${this.sortParams.key}`
      }

      if (this.searchQuery) {
        query.q = this.searchQuery
      }

      if (this.$route.query?.scope) {
        query.scope = this.$route.query?.scope
      }

      if (this.$route.query?.tab) {
        query.tab = this.$route.query?.tab
      }

      if (this.paginationParams.pageSize !== defaultPaginationParams.pageSize) {
        query.per_page = this.paginationParams.pageSize
      }

      if (this.paginationParams.current !== 1) {
        query.page = this.paginationParams.current
      }

      return query
    },
    filtersCount () {
      return this.filterParams.filter((f) => f !== 'OR').length
    },
    title () {
      return truncate(this.association?.display_name || this.model.display_name, 60)
    },
    itemsCountCacheKey () {
      return JSON.stringify({
        ...this.queryParams,
        page: {}
      })
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
        filter: this.filterParams,
        fields: this.fieldsParams,
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

      if (this.$route.query?.scope) {
        params.scope = this.$route.query?.scope
      }

      return params
    },
    includeParams () {
      return includeParams(this.model)
    },
    fieldsParams () {
      return fieldsParams(this.model)
    },
    association () {
      if (this.associationParams?.name) {
        return modelNameMap[this.resourceName].associations.find((assoc) => {
          return assoc.slug === this.associationParams.name
        })
      } else {
        return null
      }
    },
    model () {
      if (this.association) {
        const assocSchemaName = this.association.model_name

        return modelNameMap[assocSchemaName]
      } else {
        return modelNameMap[this.resourceName]
      }
    },
    columns () {
      return this.model.columns.map((column) => {
        if (column.reference?.model_name !== modelNameMap[this.resourceName].name &&
            ['read_only', 'read_write'].includes(column.access_type)) {
          return {
            key: column.name,
            title: column.display_name,
            reference: column.reference,
            format: column.format,
            sortable: !column.virtual,
            type: column.column_type
          }
        } else {
          return null
        }
      }).filter(Boolean)
    }
  },
  watch: {
    '$route' (to, from) {
      if (!to.params.doNotWatch &&
        to.name === from.name &&
        JSON.stringify(to.params.fragments) === JSON.stringify(from.params.fragments) &&
        (JSON.stringify(to.query) !== JSON.stringify(from.query))) {
        this.assignFromQueryParams(to.query)
        this.loadDataAndCount().then(() => {
          this.$refs.table.scrollToTop()
        })
      }
    },
    association: {
      deep: true,
      handler: throttle(async function (value) {
        if (value.virtual) {
          this.loadDataAndCount()
        }
      }, 3000)
    },
    columns: {
      deep: true,
      handler: throttle(async function () {
        this.loadData()
      }, 3000)
    }
  },
  mounted () {
    this.assignCachedItemsCount()
    this.assignFromQueryParams(this.$route.query)
    this.loadDataAndCount()
  },
  methods: {
    widthLessThan,
    onFinishAction (value) {
      this.loadDataAndCount()

      this.$emit('action-applied', value)
    },
    openFiltersModal () {
      this.$Drawer.open(FiltersModal, {
        filters: this.filterParams,
        model: this.model,
        onCancel: () => {
          this.$Drawer.remove()
        },
        onApply: (filters) => {
          this.filterParams = filters
          this.paginationParams.current = 1
          this.pushQueryParams()
          this.loadDataAndCount().then(() => {
            this.$refs.table.scrollToTop()
          })
          this.$Drawer.remove()
        }
      }, {
        title: this.i18n.resource_filters.replace('%{resource}', this.model.display_name),
        className: 'drawer-no-bottom-padding',
        closable: true
      })
    },
    assignFromQueryParams (query = {}) {
      this.filterParams = query.filter || []
      this.searchQuery = query.q || ''

      if (query.sort) {
        this.sortParams = {
          order: query.sort.startsWith('-') ? 'desc' : 'asc',
          key: query.sort.replace(/^-/, '')
        }
      } else {
        this.sortParams = { ...this.defaultSortParams }
      }

      this.paginationParams.current = parseInt(query.page) || 1
      this.paginationParams.pageSize = parseInt(query.per_page) || defaultPaginationParams.pageSize
    },
    loadDataAndCount () {
      return Promise.all([
        this.loadData(),
        this.loadItemsCount()
      ])
    },
    assignCachedItemsCount () {
      const count = itemsCountCache[this.itemsCountCacheKey]

      if (count) {
        this.paginationParams.total = count
      }
    },
    onPageChange () {
      this.pushQueryParams()
      this.loadData().then(() => {
        this.$refs.table.scrollToTop()
      })
    },
    onPageSizeChange () {
      this.pushQueryParams()
      this.loadData()
    },
    applySearch () {
      this.paginationParams.current = 1

      this.pushQueryParams()

      this.loadDataAndCount().then(() => {
        this.$refs.table.scrollToTop()
      })
    },
    applySort (sort) {
      this.sortParams = sort

      this.pushQueryParams()
      this.loadData()
    },
    pushQueryParams () {
      this.$router.push({ query: this.routeQueryParams, params: { doNotWatch: true } })
    },
    onRowClick (value) {
      if (this.model.primary_key) {
        this.$router.push({
          name: 'resources',
          params: {
            fragments: [...this.$route.params.fragments, value[this.model.primary_key]]
          }
        })
      }
    },
    loadItemsCount () {
      return api.get(this.queryPath, {
        params: {
          ...this.queryParams,
          meta: 'count',
          page: {
            limit: 0
          }
        }
      }).then((result) => {
        this.paginationParams.total = result.data.meta.count

        itemsCountCache[this.itemsCountCacheKey] = result.data.meta.count
      }).catch((error) => {
        console.error(error)
      })
    },
    loadData () {
      this.isLoading = true

      return api.get(this.queryPath, {
        params: this.queryParams
      }).then((result) => {
        this.rows = result.data.data
      }).catch((error) => {
        if (error.response) {
          this.$Message.error(truncate(error.response.data.errors.join('\n'), 70))
        } else {
          this.$Message.error(error.message)
        }
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
