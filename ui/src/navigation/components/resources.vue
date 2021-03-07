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
      class="h4"
      :to="{ name: 'resources', params: { fragments: [resource.slug] } }"
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
