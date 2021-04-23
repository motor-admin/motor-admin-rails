<template>
  <div class="bg-white">
    <TabsComponent
      v-if="tabs.length > 1"
      v-model="selectedTabName"
      class="mt-1"
      :tabs="tabParams"
    />
    <div
      :style="style"
      class="position-relative"
      :class="selectedTabName === 'summary' && selectedTab.tab_type === 'default' ? 'bg-white' : 'bg-body'"
    >
      <KeepAlive>
        <ResourceInfo
          v-if="selectedTabName === 'summary' && selectedTab.tab_type === 'default'"
          class="px-3 pb-3 pt-3"
          :style="{ height: '100%' }"
          :resource-name="resourceName"
          :resource-id="resourceId"
          :with-actions="true"
          :one-column="!minimized"
          @remove="$emit('remove')"
        />
        <FormTab
          v-else-if="selectedTab.tab_type === 'form'"
          :key="selectedTab.preferences.form_id"
          :tab="selectedTab"
          :data="resourceData"
        />
        <QueryTab
          v-else-if="selectedTab.tab_type === 'query'"
          :key="selectedTab.preferences.query_id"
          :tab="selectedTab"
          :variables="resourceData"
        />
        <DashboardTab
          v-else-if="selectedTab.tab_type === 'dashboard'"
          :key="selectedTab.preferences.dashboard_id"
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

export default {
  name: 'ResourceTabs',
  components: {
    TabsComponent,
    ResourceInfo,
    QueryTab,
    FormTab,
    DashboardTab
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
    model () {
      return modelNameMap[this.resourceName]
    },
    resourceData () {
      return {
        id: this.resourceId,
        [`${this.resourceName}_id`]: this.resourceId
      }
    },
    withTabs () {
      return this.tabs.length > 1
    },
    style () {
      const vh = this.minimized ? 50 : 100
      let subtract = this.minimized ? 92 : 113

      if (this.withTabs) {
        subtract += 44
      }

      return { height: `calc(${vh}vh - ${subtract}px)`, overflowY: 'scroll' }
    },
    tabs () {
      return this.model.tabs.filter((tab) => tab.visible)
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
  created () {
    this.selectedTabName = this.$route.query?.tab || this.tabs[0].name
  }
}
</script>

<style lang="scss" scoped>
:deep(.ivu-tabs-bar) {
  margin: 0;
}
</style>
