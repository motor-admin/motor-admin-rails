<template>
  <template v-if="fragments.length > 1">
    <Breadcrumbs
      :crumbs="crumbs"
      :style="{ margin: '14px 10px' }"
    />
    <Resource
      :resource-name="resourceName"
      :resource-id="resourceId"
      :association-name="associationName"
    />
  </template>
  <ResourceTable
    v-else
    :key="resourceName"
    :height="'calc(100vh - 151px)'"
    :with-title="true"
    :resource-name="resourceName"
  />
</template>

<script>
import store from 'store'
import Resource from '../components/resource'
import ResourceTable from '../components/table'
import { normalizeFragments } from 'navigation/scripts/normalize_fragments'
import Breadcrumbs from 'navigation/components/breadcrumbs'

export default {
  name: 'ResourcesBase',
  components: {
    ResourceTable,
    Resource,
    Breadcrumbs
  },
  computed: {
    fragments () {
      return this.$route.params.fragments
    },
    normalizedFragments () {
      return normalizeFragments(this.fragments, store.getters.slugsMap)
    },
    associationName () {
      const last = this.fragments[this.fragments.length - 1]

      if (this.fragments.length > 2 && !last.match(/^\d+$/)) {
        return last
      } else {
        return null
      }
    },
    resourceSlug () {
      if (this.associationName) {
        return this.fragments[this.fragments.length - 3]
      } else if (this.resourceId) {
        return this.fragments[this.fragments.length - 2]
      } else {
        return this.fragments[this.fragments.length - 1]
      }
    },
    resourceName () {
      if (store.getters.slugsMap[this.resourceSlug]) {
        return store.getters.slugsMap[this.resourceSlug].slug
      } else {
        const normalizedFragments = this.normalizedFragments
        const association = normalizedFragments.find((assoc) => assoc.fragment === this.resourceSlug)

        return association.schema.slug
      }
    },
    crumbs () {
      const fragments = this.normalizedFragments
      const crumbs = []

      for (let i = 0; i < fragments.length; i++) {
        const crumb = {
          label: fragments[i].association?.display_name || fragments[i].schema?.display_name || this.fragments[i]
        }

        if ((i - 1) !== fragments.length) {
          crumb.to = { name: 'resources', params: { fragments: this.fragments.slice(0, i + 1) } }
        }

        crumbs.push(crumb)
      }

      return crumbs
    },
    resourceId () {
      const index = this.associationName ? 2 : 1
      const last = this.fragments[this.fragments.length - index]

      if (last.match(/^\d+$/)) {
        return last
      } else {
        return null
      }
    }
  },
  methods: {
  }
}
</script>
