<template>
  <Menu
    :active-name="activeName"
    theme="light"
    width="auto"
    :open-names="openNames"
  >
    <MenuItem
      v-for="resource in resources"
      :key="resource.slug"
      :name="resource.slug"
      :class="itemClass"
      :to="{ name: 'resources', params: { fragments: [...pathFragments, resource.slug] }, query }"
    >
      {{ resource.display_name }}
    </MenuItem>
  </Menu>
</template>

<script>
export default {
  name: 'ResourcesNavigation',
  props: {
    resources: {
      type: Array,
      required: true
    },
    size: {
      type: String,
      required: false,
      default: 'default'
    },
    pathFragments: {
      type: Array,
      required: false,
      default: () => []
    },
    query: {
      type: Object,
      required: false,
      default: () => ({})
    },
    activeName: {
      type: String,
      required: false,
      default: ''
    }
  },
  data () {
    return {
      openNames: []
    }
  },
  computed: {
    itemClass () {
      if (this.size === 'small') {
        return ''
      } else {
        return 'fs-4'
      }
    }
  }
}
</script>

<style lang="scss" scoped>
.ivu-menu-item {
  padding: 14px 18px;
}
</style>
