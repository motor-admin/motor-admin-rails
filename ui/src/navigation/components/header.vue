<template>
  <div
    class="ivu-menu ivu-menu-primary ivu-menu-horizontal row m-0"
    :style="{ boxShadow: '0 1px 3px 0 rgba(0, 0, 0, 0.05)', zIndex: 1 }"
  >
    <div class="col-6 d-flex align-items-center">
      <VButton
        :to="{ name: 'home' }"
        type="primary"
        class="d-flex align-items-center justify-content-center"
        :style="{ width: '44px', height: '42px' }"
      >
        <div class="d-flex align-items-center">
          <svg
            xmlns="http://www.w3.org/2000/svg"
            class="icon icon-tabler icon-tabler-bolt"
            width="26"
            height="26"
            viewBox="0 0 24 24"
            stroke-width="2"
            stroke="currentColor"
            fill="none"
            stroke-linecap="round"
            stroke-linejoin="round"
          >
            <path
              stroke="none"
              d="M0 0h26v26H0z"
              fill="none"
            />
            <polyline points="13 3 13 10 19 10 11 21 11 14 5 14 13 3" />
          </svg>
        </div>
      </VButton>
      <VButton
        type="primary"
        :to="{ name: 'resources_home' }"
        class="ms-2"
        size="large"
      >
        Resources
      </VButton>
      <VButton
        type="primary"
        :to="{ name: 'reports' }"
        class="ms-2"
        size="large"
      >
        Reports
      </VButton>
    </div>
    <div class="col-6 d-flex justify-content-end align-items-center">
      <VButton
        type="primary"
        size="large"
        @click="openSearch"
      >
        <Icon
          type="md-search"
          size="large"
        />
      </VButton>
      <Dropdown
        trigger="click"
        transfer
        class="ms-2"
      >
        <VButton
          type="primary"
          size="large"
        >
          <Icon
            type="md-add"
            size="large"
          />
        </VButton>
        <template #list>
          <DropdownMenu>
            <DropdownItem @click="$router.push({ name: 'new_query' })">
              <Icon type="md-text" />
              Add Query
            </DropdownItem>
            <DropdownItem @click="$router.push({ name: 'new_dashboard' })">
              <Icon type="ios-pie-outline" />
              Add Dashboard
            </DropdownItem>
            <DropdownItem @click="$router.push({ name: '' })">
              <Icon type="md-alarm" />
              Add Alert
            </DropdownItem>
          </DropdownMenu>
        </template>
      </Dropdown>
      <VButton
        type="primary"
        class="ms-2"
        size="large"
      >
        <Icon
          type="md-settings"
          size="large"
        />
      </VButton>
    </div>
  </div>
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
:deep(.ivu-btn) {
  font-size: 15px;
  font-weight: 500;
  display: flex;
  align-items: center;

  .ion-md-search {
    font-size: 24px;
  }
  .ion-md-add {
    font-size: 26px;
  }
  .ion-md-settings {
    font-size: 22px;
  }
}
</style>
