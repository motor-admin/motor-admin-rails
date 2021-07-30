<template>
  <Submenu
    v-if="withScopes && hasScopes"
    :name="resource.slug"
    :collapse="false"
    :to="{ name: 'resources', params: { fragments: [...fragments, resource.slug] } }"
  >
    <template #title>
      <CustomIcon
        :type="resource.icon"
        :size="iconSize"
      />
      {{ resource.display_name.replace('/', '\u200B/') }}
    </template>

    <MenuItem
      v-for="scope in visibleScopes"
      :key="scope.name"
      :name="resource.slug + '.' + scope.name"
      :to="{ name: 'resources', params: { fragments: [...fragments, resource.slug] }, query: { scope: scope.name } }"
    >
      {{ scope.display_name.replace('/', '\u200B/') }}
    </MenuItem>
  </Submenu>
  <MenuItem
    v-else
    :name="resource.slug"
    :to="{ name: 'resources', params: { fragments: [...fragments, resource.slug] } }"
  >
    <div class="ivu-menu-item-text">
      <CustomIcon
        :type="resource.icon"
        :size="iconSize"
      />
      {{ resource.display_name.replace('/', '\u200B/') }}
    </div>
  </MenuItem>
</template>

<script>
import CustomIcon from 'utils/components/custom_icon'

export default {
  name: 'ResourceMenuItem',
  components: {
    CustomIcon
  },
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
    size: {
      type: String,
      required: false,
      default: 'default'
    },
    fragments: {
      type: Array,
      required: false,
      default: () => []
    }
  },
  computed: {
    iconSize () {
      if (this.size === 'small') {
        return 14
      } else {
        return 16
      }
    },
    visibleScopes () {
      return this.resource.scopes.filter((scope) => scope.visible)
    },
    hasScopes () {
      return !!this.visibleScopes.length
    }
  }
}
</script>

<style lang="scss">
@import 'utils/styles/variables';

@media screen and (min-width: $breakpoint-sm) {
  .ivu-menu-item-text {
    width: 164px
  }
}
</style>
