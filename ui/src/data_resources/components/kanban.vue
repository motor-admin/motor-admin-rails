<template>
  <div class="kanban-wrapper">
    <ResourceNavbar
      v-model:searchQuery="searchQuery"
      v-model:filterParams="filterParams"
      :selected-rows="selectedRows"
      :with-title="withTitle"
      :association-params="associationParams"
      :with-menu="withMenu"
      :with-resize="withResize"
      :with-kanban-toggle="true"
      :is-kanban="true"
      :resource-name="resourceName"
      @click-menu="$emit('click-menu')"
      @click-resize="$emit('click-resize')"
      @apply-search="applySearch"
      @reload="loadData"
      @action-applied="loadData"
      @apply-filters="onApplyFilters"
      @toggle-kanban="$emit('toggle-kanban')"
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
      <div class="d-flex overflow-auto border-top">
        <div
          v-for="(values, key) in groupedRows"
          :key="key"
          class="mx-2 mt-2 border rounded bg-gray"
        >
          <div class="p-2 fw-bold border-bottom">
            <Badge
              :count="values.length"
              show-zero
              :overflow-count="9999"
              type="primary"
            />
            {{ titleize(key) }}
          </div>
          <VueDraggableNext
            :list="values"
            :group="'items'"
            :style="{ height: height }"
            class="overflow-auto"
            style="width: 320px; min-height: 200px"
            @change="onMove(key, $event)"
          >
            <KanbanCard
              v-for="(item, index) in values"
              :key="item[model.primary_key] || index"
              :resource="item"
              :resource-name="model.name"
              :reference-popover="false"
              :display-columns="model.preferences.kanban_card_columns"
              class="m-2"
              @update="Object.assign(item, $event)"
              @start-action="isLoading = true"
              @finish-action="loadData"
            />
          </VueDraggableNext>
        </div>
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
import { modelNameMap } from '../scripts/schema'
import ResourceNavbar from './navbar'
import KanbanCard from './kanban_card'

import { widthLessThan } from 'utils/scripts/dimensions'
import { truncate, titleize } from 'utils/scripts/string'
import { includeParams, fieldsParams } from '../scripts/query_utils'

import { isShowSettings } from 'settings/scripts/toggle'
import SettingsMask from 'settings/components/mask'
import throttle from 'view3/src/utils/throttle'

export default {
  name: 'KanbanBoard',
  components: {
    ResourceNavbar,
    SettingsMask,
    KanbanCard
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
  emits: ['action-applied', 'click-menu', 'click-resize', 'toggle-kanban'],
  data () {
    return {
      isLoading: true,
      isReloading: true,
      rows: [],
      groupedRows: {},
      filterParams: [],
      searchQuery: ''
    }
  },
  computed: {
    isShowSettings,
    modelHasActions () {
      return this.model.actions.some((action) => action.name !== 'create' && action.visible)
    },
    kanbanColumn () {
      return this.model.columns.find((c) => c.name === this.model.preferences.kanban_column)
    },
    currentScope () {
      return this.model.scopes.find((scope) => scope.name === this.$route.query?.scope)
    },
    routeQueryParams () {
      const query = {}

      if (Object.keys(this.filterParams).length) {
        query.filter = this.filterParams
      }

      if (this.searchQuery) {
        query.q = this.searchQuery
      }

      if (this.$route.query?.scope) {
        query.scope = this.$route.query?.scope
      }

      return query
    },
    filtersCount () {
      return this.filterParams.filter((f) => f !== 'OR').length
    },
    title () {
      return truncate(this.association?.display_name || this.model.display_name, 60)
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
          limit: 2000,
          offset: 0
        }
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
            type: column.column_type
          }

          if (column.column_type === 'association') {
            const association = this.model.associations.find((assoc) => assoc.name === column.format.association_name)

            if (association) {
              tableColumn.format.association_model_name = association.model_name
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
        this.loadData()
      }
    },
    association: {
      deep: true,
      handler: throttle(async function (value) {
        if (value.virtual) {
          this.loadData()
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
    this.assignFromQueryParams(this.$route.query)
    this.loadData()
  },
  methods: {
    widthLessThan,
    titleize,
    buildGroupedRows () {
      const options = this.model.preferences.kanban_columns?.length
        ? this.model.preferences.kanban_columns
        : (Array.isArray(this.kanbanColumn.format.select_options) ? this.kanbanColumn.format.select_options : Object.keys(this.kanbanColumn.format.select_options))

      const groupsObject = options.reduce((acc, option) => {
        acc[option] = []

        return acc
      }, {})

      return this.rows.reduce((acc, row) => {
        acc[row[this.kanbanColumn.name]]?.push(row)

        return acc
      }, groupsObject)
    },
    onFinishAction (value) {
      this.loadData()

      this.$emit('action-applied', value)
    },
    onApplyFilters (filters) {
      this.filterParams = filters
      this.pushQueryParams()
      this.loadData()
    },
    assignFromQueryParams (query = {}) {
      this.filterParams = query.filter || []
      this.searchQuery = query.q || ''
    },
    applySearch () {
      this.pushQueryParams()

      this.loadData()
    },
    pushQueryParams () {
      this.$router.push({ query: this.routeQueryParams, params: { doNotWatch: true } })
    },
    onMove (key, data) {
      if (data.added) {
        this.applyDefaultUpdate(key, data.added.element).catch((error) => {
          if (error.response?.data?.errors) {
            this.$Message.error(error.response.data.errors)
          } else if (error.message) {
            this.$Message.error([error.message])
          }

          this.loadData()
        })
      }
    },
    applyDefaultUpdate (key, item) {
      return api.put(`data/${this.model.slug}/${item[this.model.primary_key]}`, {
        data: {
          [this.kanbanColumn.name]: key
        }
      })
    },
    applyCustomUpdate () {
    },
    loadData () {
      this.isLoading = true

      return api.get(this.queryPath, {
        params: this.queryParams
      }).then((result) => {
        this.rows = result.data.data
        this.groupedRows = this.buildGroupedRows()
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
