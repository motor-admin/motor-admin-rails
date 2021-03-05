<template>
  <VHeader>
    <Menu
      mode="horizontal"
      theme="dark"
      active-name="1"
    >
      <div class="layout-logo" />
      <div class="layout-nav">
        <MenuItem name="1">
          <Icon type="ios-navigate" />
          Item 1
        </MenuItem>
        <MenuItem name="2">
          <Icon type="ios-keypad" />
          Item 2
        </MenuItem>
        <MenuItem name="3">
          <Icon type="ios-analytics" />
          Item 3
        </MenuItem>
        <MenuItem name="4">
          <Icon type="ios-paper" />
          Item 4
        </MenuItem>
      </div>
    </Menu>
  </VHeader>
</template>

<script>
export default {
  name: 'AppHeader'
}
</script>
