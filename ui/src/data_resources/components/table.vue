<template>
  <div>
    <ResourceNavbar
      v-model:searchQuery="searchQuery"
      v-model:filterParams="filterParams"
      :selected-rows="selectedRows"
      :with-title="withTitle"
      :association-params="associationParams"
      :with-menu="withMenu"
      :with-resize="withResize"
      :resource-name="resourceName"
      @click-menu="$emit('click-menu')"
      @click-resize="$emit('click-resize')"
      @apply-search="applySearch"
      @reload="loadDataAndCount"
      @action-applied="loadDataAndCount"
      @apply-filters="onApplyFilters"
    />
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
        :with-select="modelHasActions"
        :render-actions="tableActions.length && canUseTableActions ? renderActions : null"
        :render-context-menu="modelHasActions && (!tableActions.length || !canUseTableActions) ? renderContextMenu : null"
        :click-rows="!!model.primary_key"
        @sort-change="applySort"
        @row-click="onRowClick"
        @row-alt-click="onRowAltClick"
        @row-meta-click="onRowMetaClick"
        @row-shift-meta-click="onRowShiftMetaClick"
        @tag-click="onTagClick"
      />
      <div class="d-flex border-top justify-content-between bg-white p-1">
        <span />
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
        <VButton
          icon="md-download"
          type="text"
          size="small"
          style="height: 24px"
          :loading="isDownloadLoading"
          class="float-right md-icon-only"
          @click="download"
        >
          {{ isDownloadLoading ? i18n.downloading : i18n.download }}
        </VButton>
      </div>
    </div>
    <div
      v-else
      :style="{ height: height.replace(/\)$/, ' + 34px)'), paddingBottom: '1px', position: 'relative' }"
    >
      <Spin fix />
    </div>
  </div>
</template>

<script>
import api from 'api'
import { reactive } from 'vue'
import { modelNameMap } from '../scripts/schema'
import DataTable from 'data_tables/components/table'
import ResourceNavbar from './navbar'
import ResourceActions from './actions'

import { widthLessThan } from 'utils/scripts/dimensions'
import { truncate, underscore } from 'utils/scripts/string'
import { formatDate } from 'utils/scripts/date_format'
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
    ResourceNavbar,
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
      isDownloadLoading: false,
      rows: [],
      sortParams: {},
      filterParams: [],
      searchQuery: '',
      paginationParams: { ...defaultPaginationParams }
    }
  },
  computed: {
    isShowSettings,
    tableActions () {
      return this.model.actions.filter((action) => {
        return action.preferences.show_on_table
      })
    },
    canUseTableActions () {
      return this.tableActions.some((action) => {
        return this.rows.some((row) => this.$can(action.name, this.model.class_name, row))
      })
    },
    editAction () {
      return this.model.actions.find((action) => {
        return action.name === 'edit' && action.visible
      })
    },
    modelHasActions () {
      return this.model.actions.some((action) => action.name !== 'create' && action.visible)
    },
    defaultSortParams () {
      if (this.model.primary_key && !this.model.custom_sql && !this.currentScope) {
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
          const tableColumn = {
            key: column.name,
            title: column.display_name,
            reference: column.reference,
            format: column.format,
            sortable: !column.virtual,
            type: column.column_type,
            description: column.description
          }

          if (column.column_type === 'association') {
            const association = this.model.associations.find((assoc) => assoc.name === column.format.association_name)

            if (association) {
              tableColumn.format.association_model_name = association.model_name
            }
          }

          if (column.name === this.model.primary_key) {
            tableColumn.reference = {
              model_name: this.model.name
            }
          }

          return tableColumn
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
    this.loadDataAndCount().then(() => {
      if (typeof history.state.tableScrollTop === 'number') {
        this.$nextTick(() => {
          this.$refs.table.scrollTo(history.state.tableScrollTop, history.state.tableScrollLeft)
        })
      }
    })
  },
  methods: {
    widthLessThan,
    onFinishAction (value) {
      this.loadDataAndCount()

      this.$emit('action-applied', value)
    },
    download () {
      this.isDownloadLoading = true

      return api.get(this.queryPath + '.csv', {
        params: this.queryParams
      }).then((result) => {
        const dateTime = formatDate(new Date(), {
          year: 'numeric',
          month: 'numeric',
          day: 'numeric',
          hour: 'numeric',
          minute: 'numeric',
          hour12: true
        }).replace(',', '')

        const dataUrl = URL.createObjectURL(new Blob([result.data], { type: 'data:text/csv;charset=utf-8' }))

        const link = document.createElement('a')

        link.setAttribute('href', dataUrl)
        link.setAttribute('download', `${underscore(this.title || 'query')}_${underscore(dateTime)}.csv`)

        link.click()
      }).catch((error) => {
        if (error.response) {
          this.$Message.error(truncate(error.response.data.errors.join('\n'), 70))
        } else {
          this.$Message.error(error.message)
        }
      }).finally(() => {
        this.isDownloadLoading = false
      })
    },
    onApplyFilters (filters) {
      this.filterParams = filters
      this.paginationParams.current = 1
      this.pushQueryParams()
      this.loadDataAndCount().then(() => {
        this.$refs.table.scrollToTop()
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
      this.paginationParams.pageSize = parseInt(query.per_page) || parseInt(localStorage.getItem(`motor:${this.model.name}:pageSize`) || '0') || defaultPaginationParams.pageSize
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

      localStorage.setItem(`motor:${this.model.name}:pageSize`, this.paginationParams.pageSize)
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
        this.$router.push(this.rowRouteParams(value))
      }
    },
    onRowAltClick (row) {
      this.rows.forEach((r) => delete r._selected)

      row._selected = true

      if (this.editAction && this.$can('edit', this.model.class_name, row)) {
        this.$nextTick(() => {
          this.$refs.actions.applyAction(this.editAction)
        })
      }
    },
    rowRouteParams (row) {
      return {
        name: 'resources',
        params: {
          fragments: [...this.$route.params.fragments, row[this.model.primary_key]]
        }
      }
    },
    onRowMetaClick (row) {
      const routeData = this.$router.resolve(this.rowRouteParams(row))

      window.open(routeData.href, '_blank')
    },
    onRowShiftMetaClick (row) {
      const routeData = this.$router.resolve(this.rowRouteParams(row))

      window.open(routeData.href, '_blank').focus()
    },
    onTagClick (data) {
      const existingFilterIndex = this.filterParams.findIndex((f) => f[data.key])

      if (existingFilterIndex === -1) {
        this.filterParams.push({ [data.key]: { eq: data.value } })
      } else {
        this.filterParams.splice(existingFilterIndex, 1, { [data.key]: { eq: data.value } })
      }

      this.pushQueryParams()

      this.loadDataAndCount().then(() => {
        this.$refs.table.scrollToTop()
      })
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
    renderContextMenu (row) {
      return (h) => {
        return h(ResourceActions, {
          resources: [row],
          label: '',
          resourceName: this.model.name,
          withButtons: false,
          withDropdown: true,
          buttonType: 'default',
          buttonGhost: false,
          buttonIcon: 'md-more',
          buttonSize: 'small',
          onStartAction: () => {
            this.isLoading = true
          },
          onFinishAction: (action) => {
            this.onFinishAction(action)
          }
        })
      }
    },
    renderActions (row) {
      return (h) => {
        return h(ResourceActions, {
          resources: [row],
          actions: this.tableActions,
          resourceName: this.model.name,
          withButtons: true,
          withDropdown: false,
          buttonSize: 'small',
          onStartAction: () => {
            this.isLoading = true
          },
          onFinishAction: (action) => {
            this.onFinishAction(action)
          }
        })
      }
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
