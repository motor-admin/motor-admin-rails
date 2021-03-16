<template>
  <Menu
    mode="horizontal"
    theme="light"
    active-name="1"
    class="row m-0"
    :style="{ boxShadow: '0 1px 3px 0 rgba(0, 0, 0, 0.05)', zIndex: 1 }"
  >
    <div class="col-4 ps-4">
      <RouterLink :to="{name: 'home'}">
        <h2>
          ⚙️ MotorAdmin
        </h2>
      </RouterLink>
    </div>
    <div class="col-4">
      <Search :placeholder="'Search'" />
    </div>
    <div class="col-4 d-flex justify-content-end">
      <MenuItem
        name="1"
        :to="{ name: 'resources_home' }"
      >
        Resources
      </MenuItem>
      <MenuItem
        name="3"
        :to="{ name: 'new_query' }"
      >
        Queries
      </MenuItem>
      <MenuItem name="2">
        Dashboards
      </MenuItem>
      <MenuItem name="4">
        Settings
      </MenuItem>
    </div>
  </Menu>
</template>

<script>
import Search from './search'

export default {
  name: 'AppHeader',
  components: {
    Search
  }
}
</script>
