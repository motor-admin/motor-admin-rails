<template>
  <Resource
    v-if="fragments.length > 1"
    :resource-name="resourceName"
    :resource-id="resourceId"
    :association-name="associationName"
  />
  <ResourceTable
    v-else
    :height="'calc(100vh - 151px)'"
    :resource-name="resourceName"
  />
</template>

<script>
import store from 'store'
import Resource from '../components/resource'
import ResourceTable from '../components/table'
import { normalizeFragments } from 'navigation/scripts/normalize_fragments'

export default {
  name: 'ResourcesBase',
  components: {
    ResourceTable,
    Resource
  },
  data () {
    return {}
  },
  computed: {
    fragments () {
      return this.$route.params.fragments
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
        const normalizedFragments = normalizeFragments(this.fragments, store.getters.slugsMap)
        const association = normalizedFragments.find((assoc) => assoc.fragment === this.resourceSlug)

        return association.schema.slug
      }
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
