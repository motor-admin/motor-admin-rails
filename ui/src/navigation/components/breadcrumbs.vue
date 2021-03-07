<template>
  <Breadcrumb>
    <BreadcrumbItem
      v-for="(crumb, index) in crumbs"
      :key="index"
      :to="crumb.to"
    >
      {{ crumb.label }}
    </BreadcrumbItem>
  </Breadcrumb>
</template>

<script>
import store from 'store'

export default {
  name: 'AppBreadcrumbs',
  computed: {
    fragments () {
      return this.$route.params.fragments || []
    },
    crumbs () {
      const slugsMap = store.getters.slugsMap
      const fragments = this.fragments
      const crumbs = []

      for (let i = fragments.length; i > 0; i--) {
        const crumb = {
          label: slugsMap[fragments[i - 1]]?.display_name || fragments[i - 1]
        }

        if (i !== fragments.length) {
          crumb.to = { name: 'resources', params: { fragments: fragments.slice(0, i) } }
        }

        crumbs.push(crumb)
      }

      return crumbs.reverse()
    }
  }
}
</script>
