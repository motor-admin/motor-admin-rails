<template>
  <Layout :has-sider="!!associations.length">
    <Sider
      v-if="associations.length"
      :style="{ background: '#fff' }"
    >
      <ResourcesMenu
        :resources="associations"
        :item-class="'h5'"
        :path-fragments="pathFragments"
        :active-name="associationName"
        class="border-top"
        :style="{ maxHeight: 'calc(100vh - 116px)', overflowY: 'scroll', minHeight: '100%' }"
      />
    </Sider>
    <Layout>
      <Content>
        <ResourceInfo
          :key="resourceName + resourceId"
          :resource-name="resourceName"
          :resource-id="resourceId"
          :one-column="!showTable"
          class="border-top p-3"
          :style="infoStyle"
        />
        <ResourceTable
          v-if="showTable"
          :key="resourceName + resourceId + associationName"
          :height="'calc(50vh - 58px)'"
          :resource-name="resourceName"
          :association-params="{ name: associationName, id: resourceId }"
        />
      </Content>
    </Layout>
  </Layout>
</template>

<script>
import store from 'store'

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
        return { height: 'calc(50vh - 94px)', overflowY: 'scroll' }
      } else {
        return { height: 'calc(100vh - 116px)', overflowY: 'scroll' }
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
      return store.getters.slugsMap[this.resourceName].associations.filter((assoc) => {
        return assoc.association_type === 'has_many'
      })
    }
  },
  methods: {
  }
}
</script>
