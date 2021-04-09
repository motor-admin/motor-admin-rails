<template>
  <Menu
    mode="horizontal"
    theme="light"
    active-name="1"
    class="row m-0"
    :style="{ boxShadow: '0 1px 3px 0 rgba(0, 0, 0, 0.05)', zIndex: 1 }"
  >
    <div class="col-6 ps-4 d-flex">
      <MenuItem
        name="1"
        :to="{ name: 'home' }"
      >
        <Icon type="md-cog" />
      </MenuItem>
      <MenuItem
        name="2"
        :to="{ name: 'resources_home' }"
      >
        Resources
      </MenuItem>
      <MenuItem
        name="3"
        :to="{ name: 'reports' }"
      >
        Reports
      </MenuItem>
    </div>
    <div class="col-6 d-flex justify-content-end">
      <MenuItem
        name="4"
        @click="openSearch"
      >
        <Icon
          type="md-search"
          size="large"
        />
      </MenuItem>
      <Submenu
        name="add"
      >
        <MenuItem
          name="10"
          :to="{ name: 'new_query' }"
        >
          <Icon type="md-text" />
          Add Query
        </MenuItem>
        <MenuItem
          name="11"
          :to="{ name: 'new_dashboard' }"
        >
          <Icon type="ios-pie-outline" />
          Add Dashboard
        </MenuItem>
        <MenuItem
          name="12"
          :to="{}"
        >
          <Icon type="md-alarm" />
          Add Alert
        </MenuItem>
      </Submenu>
      <MenuItem name="5">
        <Icon
          type="md-settings"
          size="large"
        />
      </MenuItem>
    </div>
  </Menu>
</template>

<script>
import Search from './search'

export default {
  name: 'AppHeader',
  methods: {
    openSearch () {
      this.$Modal.open(Search, {
        placeholder: 'Search...',
        onSelected: (value) => {
          this.$Modal.remove()
        }
      })
    }
  }
}
</script>

<style lang="scss" scoped>
.ion {
  font-size: 16px;
}

:deep(.ivu-menu-submenu-title-icon) {
  font-size: 16px !important;

  &:before {
    content: "\f273" !important;
  }
}
</style>
