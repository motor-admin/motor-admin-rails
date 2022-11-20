<template>
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
      <VButton
        v-if="withKanbanToggle"
        :icon="isKanban ? 'md-grid' : 'ios-browsers'"
        class="me-2"
        @click="$emit('toggle-kanban')"
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
        v-if="withTitle && !widthLessThan('sm') && (!selectedRows.length || !modelHasActions)"
        class="fs-4 fw-bold nowrap overflow-hidden text-truncate"
      >{{ title }}
        <template v-if="currentScope">
          ({{ currentScope.display_name }})
        </template>
      </span>
      <ResourceActions
        v-if="selectedRows.length && !isShowSettings && modelHasActions"
        ref="actions"
        :resources="selectedRows"
        :with-deselect="true"
        :resource-name="model.name"
        :label="`${i18n['actions']} (${selectedRows.length})`"
        @start-action="$emit('start-action')"
        @finish-action="onFinishAction"
      />
    </div>
    <div
      class="d-flex justify-content-end"
      :class="(withTitle && !widthLessThan('sm')) || selectedRows.length ? 'col-6' : 'col-12'"
    >
      <ResourceSearch
        :model-value="searchQuery"
        style="max-width: 470px"
        class="me-1"
        :placeholder="`${i18n['search']} ${(association?.display_name || model.display_name).toLowerCase()}...`"
        @search="$emit('apply-search')"
        @update:model-value="$emit('update:searchQuery', $event)"
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
      <CollectionActions
        class="ms-1"
        :model="model"
        :association="association"
        :parent-resource="associationParams ? { name: resourceName, id: associationParams.id } : null"
        @success="$emit('reload')"
      />
    </div>
  </div>
</template>

<script>
import { modelNameMap } from '../scripts/schema'
import ResourceSearch from './search'
import ResourceActions from './actions'
import CollectionActions from './collection_actions'
import FiltersModal from './filters_modal'

import { widthLessThan } from 'utils/scripts/dimensions'
import { truncate } from 'utils/scripts/string'

import { isShowSettings } from 'settings/scripts/toggle'
import SettingsMask from 'settings/components/mask'

export default {
  name: 'ResourceNavbar',
  components: {
    ResourceSearch,
    ResourceActions,
    CollectionActions,
    SettingsMask
  },
  props: {
    resourceName: {
      type: String,
      required: true
    },
    filterParams: {
      type: Array,
      required: false,
      default: () => ([])
    },
    selectedRows: {
      type: Array,
      required: false,
      default: () => ([])
    },
    searchQuery: {
      type: String,
      required: true,
      default: ''
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
    withKanbanToggle: {
      type: Boolean,
      required: false,
      default: false
    },
    isKanban: {
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
  emits: ['click-resize', 'click-menu', 'action-applied', 'update:filterParams', 'update:searchQuery', 'apply-search', 'apply-filters', 'reload', 'start-action', 'toggle-kanban'],
  computed: {
    isShowSettings,
    currentScope () {
      return this.model.scopes.find((scope) => scope.name === this.$route.query?.scope)
    },
    modelHasActions () {
      return this.model.actions.some((action) => action.name !== 'create' && action.visible)
    },
    filtersCount () {
      return this.filterParams.filter((f) => f !== 'OR').length
    },
    title () {
      return truncate(this.association?.display_name || this.model.display_name, 60)
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
    }
  },
  methods: {
    widthLessThan,
    onFinishAction (value) {
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
          this.$emit('update:filterParams', filters)
          this.$emit('apply-filters', filters)

          this.$Drawer.remove()
        }
      }, {
        title: this.i18n.resource_filters.replace('%{resource}', this.model.display_name),
        className: 'drawer-no-bottom-padding',
        closable: true
      })
    }
  }
}
</script>
