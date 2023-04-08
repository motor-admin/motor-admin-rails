<template>
  <Layout
    :has-sider="!!associations.length"
    class="position-relative"
  >
    <Sider
      v-if="associations.length && !widthLessThan('sm')"
      class="border-top"
      :style="{ background: '#fff', maxHeight: 'calc(var(--vh, 100vh) - 112px)' }"
    >
      <ResourcesMenu
        :resources="associations"
        :size="'small'"
        :with-scopes="false"
        :path-fragments="pathFragments"
        :active-name="associationName"
        :style="{ minHeight: '100%' }"
      />
    </Sider>
    <SettingsMask
      v-if="isShowSettings && associations.length && !widthLessThan('sm')"
      :settings-type="'associations'"
      :resource="model"
      style="width: 200px"
    />
    <Layout>
      <ResourceTabs
        v-if="!showTable || !isFullscreenTable"
        :key="resourceName + resourceId"
        ref="tabs"
        :resource-name="resourceName"
        :resource-id="resourceId"
        :minimized="showTable"
        class="border-top"
        @remove="goToParent"
      />
      <AttachmentsList
        v-if="showTable && association?.model_name === 'active_storage/attachment'"
        :key="resourceName + resourceId + associationName"
        :height="isFullscreenTable ? 'calc(var(--vh, 100vh) - 199px)' : 'calc((var(--vh) / 2) - 108px)'"
        :with-resize="true"
        :resource-name="resourceName"
        :with-title="true"
        class="border-top"
        :association-params="{ name: associationName, id: resourceId }"
        @action-applied="reloadTabs"
        @click-resize="toggleSize"
      />
      <ResourceKanban
        v-else-if="showTable && associationModel.preferences.display_as === 'kanban' && isKanban"
        :key="resourceName + resourceId + associationName"
        :height="isFullscreenTable ? 'calc(var(--vh, 100vh) - 219px)' : 'calc((var(--vh) / 2) - 128px)'"
        :with-resize="true"
        :resource-name="resourceName"
        :with-title="true"
        class="border-top"
        :association-params="{ name: associationName, id: resourceId }"
        @action-applied="reloadTabs"
        @click-resize="toggleSize"
        @toggle-kanban="toggleKanban"
      />
      <ResourceTable
        v-else-if="showTable"
        ref="table"
        :key="resourceName + resourceId + associationName"
        :height="isFullscreenTable ? 'calc(var(--vh, 100vh) - 199px)' : 'calc((var(--vh) / 2) - 108px)'"
        :with-resize="true"
        :resource-name="resourceName"
        :with-title="true"
        :with-kanban-toggle="associationModel.preferences.display_as === 'kanban'"
        class="border-top"
        :association-params="{ name: associationName, id: resourceId }"
        @action-applied="reloadTabs"
        @click-resize="toggleSize"
        @toggle-kanban="toggleKanban"
      />
    </Layout>
  </Layout>
</template>

<script>
import { modelNameMap } from '../scripts/schema'

import ResourcesMenu from 'navigation/components/resources'
import ResourceTable from './table'
import ResourceKanban from './kanban'
import ResourceTabs from './tabs'
import AttachmentsList from './attachments_list'

import { widthLessThan } from 'utils/scripts/dimensions'
import { isShowSettings } from 'settings/scripts/toggle'
import SettingsMask from 'settings/components/mask'

const fullscreenTableKey = 'resources:fullscreenAssociationTable'

export default {
  name: 'ResourcesShow',
  components: {
    ResourcesMenu,
    ResourceTable,
    ResourceTabs,
    SettingsMask,
    ResourceKanban,
    AttachmentsList
  },
  props: {
    resourceName: {
      type: String,
      required: true
    },
    associationName: {
      type: String,
      required: false,
      default: ''
    },
    resourceId: {
      type: [String, Number],
      required: true
    }
  },
  data () {
    return {
      isFullscreenTable: false,
      isKanban: this.$route.query?.display_as === 'kanban'
    }
  },
  computed: {
    isShowSettings,
    showTable () {
      return !!this.associationName
    },
    pathFragments () {
      const fragments = this.$route.params.fragments

      if (this.associationName) {
        return fragments.slice(0, fragments.length - 1)
      } else {
        return fragments
      }
    },
    model () {
      return modelNameMap[this.resourceName]
    },
    association () {
      return this.associations.find((assoc) => assoc.name === this.associationName)
    },
    associationModel () {
      return modelNameMap[this.association.model_name]
    },
    associations () {
      return this.model.associations.filter((assoc) => assoc.visible && modelNameMap[assoc.model_name])
    }
  },
  created () {
    if (widthLessThan('sm')) {
      this.isFullscreenTable = true
    } else {
      this.isFullscreenTable = localStorage.getItem(fullscreenTableKey) === 'true'
    }

    this.isKanban ||= localStorage.getItem(`motor:${this.model.name}:is_kanban`) !== 'false'
  },
  methods: {
    widthLessThan,
    reloadTabs () {
      if (this.$refs.tabs) {
        this.$refs.tabs.reload()
      }
    },
    toggleSize () {
      this.isFullscreenTable = !this.isFullscreenTable

      localStorage.setItem(fullscreenTableKey, this.isFullscreenTable.toString())
    },
    toggleKanban () {
      this.isKanban = !this.isKanban

      localStorage.setItem(`motor:${this.model.name}:is_kanban`, this.isKanban)
    },
    goToParent () {
      this.$router.push({
        name: 'resources',
        params: {
          fragments: this.pathFragments.slice(0, this.pathFragments.length - 1)
        }
      })
    }
  }
}
</script>
