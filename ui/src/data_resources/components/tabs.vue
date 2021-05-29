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
      :class="isDefaultDetails ? 'bg-white' : 'bg-body'"
    >
      <SettingsMask
        v-if="isShowSettings && !isDefaultDetails"
        :settings-type="selectedTab.tab_type"
        :preferences="selectedTab.preferences"
      />
      <KeepAlive>
        <ResourcesMenu
          v-if="selectedTabName === 'assiciations'"
          :key="'associations'"
          :resources="associations"
          :size="'small'"
          :with-scopes="false"
          :path-fragments="$route.params.fragments"
          :style="{ minHeight: '100%' }"
        />
        <ResourceInfo
          v-else-if="isDefaultDetails"
          :key="'details'"
          ref="details"
          class="px-3 pt-3"
          :style="{ height: '100%' }"
          :resource-name="resourceName"
          :resource-id="resourceId"
          :with-actions="true"
          :editable="true"
          :one-column="!minimized"
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
      </KeepAlive>
    </div>
  </div>
</template>

<script>
import TabsComponent from 'utils/components/tabs'
import ResourceInfo from './info'
import { modelNameMap } from '../scripts/schema'
import QueryTab from './query_tab'
import FormTab from './form_tab'
import DashboardTab from './dashboard_tab'
import ResourcesMenu from 'navigation/components/resources'

import { isShowSettings } from 'settings/scripts/toggle'
import SettingsMask from 'settings/components/mask'
import { widthLessThan } from 'utils/scripts/dimensions'

export default {
  name: 'ResourceTabs',
  components: {
    TabsComponent,
    ResourceInfo,
    QueryTab,
    FormTab,
    DashboardTab,
    ResourcesMenu,
    SettingsMask
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
    style () {
      const vh = this.minimized ? '(var(--vh) / 2)' : 'var(--vh)'
      let subtract = this.minimized ? 92 : 113

      if (this.withTabs) {
        subtract += 44
      }

      return { height: `calc(${vh} - ${subtract}px)`, overflowY: this.isShowSettings ? 'hidden' : 'scroll' }
    },
    tabs () {
      const tabs = this.model.tabs.filter((tab) => tab.visible)

      if (this.associations.length && widthLessThan('sm')) {
        tabs.splice(1, 0, {
          name: 'assiciations',
          display_name: 'Assiciations'
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
