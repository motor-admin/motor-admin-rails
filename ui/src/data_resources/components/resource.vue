<template>
  <Layout :has-sider="!!associations.length">
    <Sider
      v-if="associations.length && !widthLessThan('sm')"
      class="border-top"
      :style="{ background: '#fff', maxHeight: 'calc(var(--vh, 100vh) - 112px)', overflowY: 'scroll' }"
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
    <Layout>
      <Content>
        <ResourceTabs
          v-if="!showTable || !isFullscreenTable"
          :key="resourceName + resourceId"
          :resource-name="resourceName"
          :resource-id="resourceId"
          :minimized="showTable"
          class="border-top"
          @remove="goToParent"
        />
        <ResourceTable
          v-if="showTable"
          :key="resourceName + resourceId + associationName"
          :height="isFullscreenTable ? 'calc(var(--vh, 100vh) - 199px)' : 'calc((var(--vh) / 2) - 108px)'"
          :with-resize="true"
          :resource-name="resourceName"
          :with-title="!widthLessThan('sm')"
          class="border-top"
          :association-params="{ name: associationName, id: resourceId }"
          @click-resize="toggleSize"
        />
      </Content>
    </Layout>
  </Layout>
</template>

<script>
import { modelNameMap } from '../scripts/schema'

import ResourcesMenu from 'navigation/components/resources'
import ResourceTable from './table'
import ResourceTabs from './tabs'

import { widthLessThan } from 'utils/scripts/dimensions'

const fullscreenTableKey = 'resources:fullscreenAssociationTable'

export default {
  name: 'ResourcesShow',
  components: {
    ResourcesMenu,
    ResourceTable,
    ResourceTabs
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
      isFullscreenTable: false
    }
  },
  computed: {
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
    associations () {
      return this.model.associations.filter((assoc) => assoc.visible)
    }
  },
  created () {
    if (widthLessThan('sm')) {
      this.isFullscreenTable = true
    } else {
      this.isFullscreenTable = localStorage.getItem(fullscreenTableKey) === 'true'
    }
  },
  methods: {
    widthLessThan,
    toggleSize () {
      this.isFullscreenTable = !this.isFullscreenTable

      localStorage.setItem(fullscreenTableKey, this.isFullscreenTable.toString())
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
