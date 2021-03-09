<template>
  <Breadcrumb>
    <BreadcrumbItem
      v-for="(crumb, index) in crumbs"
      :key="index"
      :to="crumb.to"
      class="h4"
    >
      {{ crumb.label }}
    </BreadcrumbItem>
  </Breadcrumb>
</template>

<script>
import store from 'store'
import { normalizeFragments } from 'navigation/scripts/normalize_fragments'

export default {
  name: 'AppBreadcrumbs',
  computed: {
    fragments () {
      return this.$route.params.fragments || []
    },
    crumbs () {
      const fragments = normalizeFragments(this.fragments, store.getters.slugsMap)
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
    }
  }
}
</script>
