<template>
  <Layout :has-sider="!!associations.length">
    <Sider
      v-if="associations.length"
      class="border-top"
      :style="{ background: '#fff', maxHeight: 'calc(100vh - 112px)', overflowY: 'scroll' }"
    >
      <ResourcesMenu
        :resources="associations"
        :item-class="'h5'"
        :path-fragments="pathFragments"
        :active-name="associationName"
        :style="{ minHeight: '100%' }"
      />
    </Sider>
    <Layout>
      <Content>
        <ResourceInfo
          :key="resourceName + resourceId"
          :resource-name="resourceName"
          :resource-id="resourceId"
          :with-actions="true"
          :one-column="!showTable"
          class="border-top p-3"
          :style="infoStyle"
          @remove="goToParent"
        />
        <ResourceTable
          v-if="showTable"
          :key="resourceName + resourceId + associationName"
          :height="'calc(50vh - 108px)'"
          :resource-name="resourceName"
          :with-title="true"
          class="border-top"
          :association-params="{ name: associationName, id: resourceId }"
        />
      </Content>
    </Layout>
  </Layout>
</template>

<script>
import { modelNameMap } from 'utils/scripts/schema'

import ResourcesMenu from 'navigation/components/resources'
import ResourceTable from './table'
import ResourceInfo from './info'

export default {
  name: 'ResourcesShow',
  components: {
    ResourcesMenu,
    ResourceTable,
    ResourceInfo
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
  computed: {
    infoStyle () {
      if (this.showTable) {
        return { height: 'calc(50vh - 91px)', overflowY: 'scroll' }
      } else {
        return { height: 'calc(100vh - 112px)', overflowY: 'scroll' }
      }
    },
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
    associations () {
      return modelNameMap[this.resourceName].associations.filter((assoc) => {
        return assoc.association_type === 'has_many'
      })
    }
  },
  methods: {
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
