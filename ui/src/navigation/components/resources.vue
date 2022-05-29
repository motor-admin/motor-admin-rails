<template>
  <Menu
    :active-name="activeName"
    theme="light"
    width="auto"
    :open-names="openNames"
    @on-select="$emit('select', $event)"
  >
    <ResourceMenuItem
      v-for="resource in resources"
      :key="resource.slug"
      :size="size"
      :with-scopes="withScopes"
      :fragments="pathFragments"
      :resource="resource"
      :class="itemClass"
    />
  </Menu>
</template>

<script>
import ResourceMenuItem from './resource_menu_item'

export default {
  name: 'ResourcesNavigation',
  components: {
    ResourceMenuItem
  },
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
    withScopes: {
      type: Boolean,
      required: false,
      default: true
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
  emits: ['select'],
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
.ivu-menu-item, :deep(.ivu-menu-submenu-title) {
  line-break: normal;
}

.ivu-menu-item, :deep(.ivu-menu-submenu-title) {
  padding: 14px 18px;
}

.ivu-menu.ivu-menu-light.ivu-menu-vertical {
  & > .ivu-menu-item-active:not(.ivu-menu-submenu) {
    font-weight: 500;
  }
}

.ivu-menu.ivu-menu-light.ivu-menu-vertical {
  .ivu-menu-submenu {
    :deep(.ivu-menu-item) {
      padding-top: 7px;
      padding-bottom: 7px;
      padding-left: 39px;
    }

    :deep(.ivu-menu-item.ivu-menu-item-active) {
      font-weight: 500;
    }

    &.ivu-menu-item-active {
      :deep(.ivu-menu-submenu-title) {
        font-weight: 500;
      }
    }
  }
}
</style>
