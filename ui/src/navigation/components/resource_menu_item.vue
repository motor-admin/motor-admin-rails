<template>
  <Submenu
    v-if="withScopes && hasScopes"
    :name="resource.slug"
    :collapse="false"
    :to="{ name: 'resources', params: { fragments: [...fragments, resource.slug] } }"
  >
    <template #title>
      {{ resource.display_name }}
    </template>

    <MenuItem
      v-for="scope in visibleScopes"
      :key="scope.name"
      :name="resource.slug + '.' + scope.name"
      :to="{ name: 'resources', params: { fragments: [...fragments, resource.slug] }, query: { scope: scope.name } }"
    >
      {{ scope.display_name }}
    </MenuItem>
  </Submenu>
  <MenuItem
    v-else
    :name="resource.slug"
    :to="{ name: 'resources', params: { fragments: [...fragments, resource.slug] } }"
  >
    {{ resource.display_name }}
  </MenuItem>
</template>

<script>
export default {
  name: 'ResourceMenuItem',
  props: {
    resource: {
      type: Object,
      required: true
    },
    withScopes: {
      type: Boolean,
      required: false,
      default: true
    },
    fragments: {
      type: Array,
      required: false,
      default: () => []
    }
  },
  computed: {
    visibleScopes () {
      return this.resource.scopes.filter((scope) => scope.visible)
    },
    hasScopes () {
      return !!this.visibleScopes.length
    }
  }
}
</script>
