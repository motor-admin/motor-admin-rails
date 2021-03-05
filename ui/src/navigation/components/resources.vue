<template>
  <Menu
    active-name="1-2"
    theme="light"
    width="auto"
    :open-names="openNames"
  >
    <MenuItem
      v-for="resource in resources"
      :key="resource.name"
      :name="resource.name"
      :to="{ name: 'resources', params: { fragments: [resource.slug] } }"
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
