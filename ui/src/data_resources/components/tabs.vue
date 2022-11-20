<template>
  <div class="bg-white">
    <TabsComponent
      v-if="withTabs"
      v-model="selectedTabName"
      class="pt-1"
      :tabs="tabParams"
    >
      <SettingsMask
        v-if="isShowSettings"
        :settings-type="'tabs'"
        :resource="model"
      />
    </TabsComponent>
    <div
      :style="style"
      class="position-relative"
      :class="isDefaultDetails || isQueryDetails ? 'bg-white' : 'bg-body'"
    >
      <SettingsMask
        v-if="isShowSettings && !isDefaultDetails && !isQueryDetails"
        :settings-type="selectedTab.tab_type"
        :preferences="selectedTab.preferences"
      />
      <ResourcesMenu
        v-if="selectedTabName === 'associations'"
        :key="'associations'"
        :resources="associations"
        :size="'small'"
        :with-scopes="false"
        :path-fragments="$route.params.fragments.length % 2 === 1 ? $route.params.fragments.slice(0, -1) : $route.params.fragments"
        :style="{ minHeight: '100%' }"
      />
      <ResourceInfo
        v-else-if="isDefaultDetails"
        :key="'details'"
        ref="details"
        class="px-3 pb-3"
        :resource-name="resourceName"
        :resource-id="resourceId"
        :with-actions="true"
        :with-sticky-title="true"
        :editable="true"
        :one-column="!minimized"
        @remove="$emit('remove')"
      />
      <AuditsTab
        v-else-if="isDefaultAudits"
        :key="'audits'"
        ref="audits"
        class="px-3 pb-3"
        :resource-name="resourceName"
        :resource-id="resourceId"
      />
      <NotesTab
        v-else-if="isDefaultNotes"
        :key="'notes'"
        ref="notes"
        :resource-name="resourceName"
        :minimized="minimized"
        :resource-id="resourceId"
      />
      <ResourceInfoQuery
        v-else-if="isQueryDetails"
        :key="selectedTab.tab_type + selectedTab.preferences.query_id"
        ref="query"
        class="px-3 pt-3"
        :resource-name="resourceName"
        :resource-id="resourceId"
        @remove="$emit('remove')"
      />
      <FormTab
        v-else-if="selectedTab.tab_type === 'form'"
        :key="selectedTab.tab_type + selectedTab.preferences.form_id"
        :tab="selectedTab"
        :data="resourceData"
      />
      <QueryTab
        v-else-if="selectedTab.tab_type === 'query'"
        :key="selectedTab.tab_type + selectedTab.preferences.query_id"
        ref="query"
        :tab="selectedTab"
        :variables="resourceData"
      />
      <DashboardTab
        v-else-if="selectedTab.tab_type === 'dashboard'"
        :key="selectedTab.tab_type + selectedTab.preferences.dashboard_id"
        ref="dashboard"
        :tab="selectedTab"
        :variables="resourceData"
      />
    </div>
  </div>
</template>

<script>
import TabsComponent from 'utils/components/tabs'
import ResourceInfo from './info'
import ResourceInfoQuery from './info_query'
import { modelNameMap } from '../scripts/schema'
import QueryTab from './query_tab'
import FormTab from './form_tab'
import DashboardTab from './dashboard_tab'
import AuditsTab from './audits_tab'
import ResourcesMenu from 'navigation/components/resources'
import NotesTab from 'notes/components/notes'

import { dashboardsStore, queriesStore } from 'reports/scripts/store'
import { formsStore } from 'custom_forms/scripts/store'

import { isShowSettings } from 'settings/scripts/toggle'
import SettingsMask from 'settings/components/mask'
import { widthLessThan } from 'utils/scripts/dimensions'

const tabResources = {
  dashboard: dashboardsStore,
  form: formsStore,
  query: queriesStore
}

export default {
  name: 'ResourceTabs',
  components: {
    TabsComponent,
    ResourceInfo,
    QueryTab,
    FormTab,
    DashboardTab,
    ResourcesMenu,
    SettingsMask,
    ResourceInfoQuery,
    AuditsTab,
    NotesTab
  },
  props: {
    resourceName: {
      type: String,
      required: true
    },
    resourceId: {
      type: [Number, String],
      required: true
    },
    minimized: {
      type: Boolean,
      required: false,
      default: false
    }
  },
  emits: ['remove'],
  data () {
    return {
      selectedTabName: ''
    }
  },
  computed: {
    isShowSettings,
    model () {
      return modelNameMap[this.resourceName]
    },
    associations () {
      return this.model.associations.filter((assoc) => assoc.visible)
    },
    resourceData () {
      return {
        id: this.resourceId,
        [`${this.resourceName}_id`]: this.resourceId
      }
    },
    withTabs () {
      return this.tabs.length > 1 || this.isShowSettings
    },
    isDefaultDetails () {
      return this.selectedTabName === 'details' && this.selectedTab.tab_type === 'default'
    },
    isDefaultAudits () {
      return this.selectedTabName === 'audits' && this.selectedTab.tab_type === 'default'
    },
    isDefaultNotes () {
      return this.selectedTabName === 'notes' && this.selectedTab.tab_type === 'default'
    },
    isQueryDetails () {
      return this.selectedTabName === 'details' && this.selectedTab.tab_type === 'query'
    },
    style () {
      const vh = this.minimized ? '(var(--vh) / 2)' : 'var(--vh)'
      let subtract = this.minimized ? 92 : 113

      if (this.withTabs) {
        subtract += 44
      }

      return { height: `calc(${vh} - ${subtract}px)`, overflowY: this.isShowSettings ? 'hidden' : 'auto' }
    },
    tabs () {
      const tabs = this.model.tabs.filter((tab) => {
        return tab.visible && (tab.tab_type === 'default' || tabResources[tab.tab_type].find((e) => e.id.toString() === tab.preferences[`${tab.tab_type}_id`].toString()))
      })

      if (this.associations.length && widthLessThan('sm')) {
        tabs.splice(1, 0, {
          name: 'associations',
          display_name: this.i18n.associations
        })
      }

      return tabs
    },
    selectedTab () {
      return this.tabs.find((tab) => tab.name === this.selectedTabName)
    },
    tabParams () {
      return this.tabs.map((tab) => {
        return { to: { query: { tab: tab.name }, params: { doNotWatch: true } }, label: tab.display_name, value: tab.name }
      })
    }
  },
  watch: {
    '$route' (to, from) {
      if (to.name === from.name && JSON.stringify(to.params.fragments) === JSON.stringify(from.params.fragments)) {
        this.selectedTabName = to.query?.tab || this.tabs[0].name
      }
    }
  },
  created () {
    this.selectedTabName = this.$route.query?.tab || this.tabs[0].name
  },
  methods: {
    reload () {
      if (this.$refs.details) {
        this.$refs.details.loadData()
      } else if (this.$refs.query) {
        this.$refs.query.runQuery()
      } else if (this.$refs.dashboard) {
        this.$refs.dashboard.$refs.layout.reload()
      }
    }
  }
}
</script>

<style lang="scss" scoped>
:deep(.ivu-tabs-bar) {
  margin: 0;
}
</style>
