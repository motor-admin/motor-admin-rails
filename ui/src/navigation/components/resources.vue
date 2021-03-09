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
      :to="{ name: 'resources', params: { fragments: [...pathFragments, resource.slug] } }"
    >
      <Icon type="md-list" />
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
    itemClass: {
      type: String,
      required: false,
      default: 'h4'
    },
    pathFragments: {
      type: Array,
      required: false,
      default: () => []
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
  mounted () {
  }
}
</script>
