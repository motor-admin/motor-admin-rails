<template>
  <div
    class="ivu-menu ivu-menu-primary ivu-menu-horizontal row m-0"
    :style="{ boxShadow: '0 1px 3px 0 rgba(0, 0, 0, 0.05)', zIndex: 1 }"
  >
    <div class="col-10 d-flex align-items-center">
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
        :to="{ name: 'reports' }"
        class="header-btn ms-2"
        size="large"
      >
        Reports
      </VButton>
      <VButton
        type="primary"
        class="header-btn ms-2"
        size="large"
        :to="{ name: 'forms' }"
      >
        Forms
      </VButton>
      <VButton
        :is="link.component"
        v-for="link in linksToRender"
        :key="link.name"
        type="primary"
        class="header-btn ms-2"
        :target="link.target"
        size="large"
        :to="link.to"
      >
        {{ link.name }}
      </VButton>
      <VButton
        type="primary"
        class="ms-2 add-item-btn"
        icon="md-add"
        @click="openEditModal"
      />
    </div>
    <div class="col-2 d-flex justify-content-end align-items-center">
      <VButton
        type="primary"
        size="large"
        class="header-btn"
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
          class="header-btn"
        >
          <Icon
            type="md-add"
            size="large"
          />
        </VButton>
        <template #list>
          <DropdownMenu>
            <DropdownItem @click="$router.push({ name: 'new_query' })">
              Add Query
            </DropdownItem>
            <DropdownItem @click="$router.push({ name: 'new_dashboard' })">
              Add Dashboard
            </DropdownItem>
            <DropdownItem @click="$router.push({ name: 'new_form'})">
              Add Form
            </DropdownItem>
            <DropdownItem @click="$router.push({ name: 'new_alert' })">
              Add Alert
            </DropdownItem>
          </DropdownMenu>
        </template>
      </Dropdown>
      <VButton
        type="primary"
        class="ms-2 header-btn"
        size="large"
        @click="openSettings"
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
import ResourcesSettings from 'settings/components/resources_list'
import HeaderEdit from './header_edit'
import { modelSlugMap } from 'data_resources/scripts/schema'
import { basePath } from 'utils/scripts/configs'

export default {
  name: 'AppHeader',
  data () {
    return {
      links: JSON.parse(document.getElementById('app').getAttribute('data-header-links'))
    }
  },
  computed: {
    linksToRender () {
      return this.links.map((link) => {
        const params = { name: link.name }

        const path = link.path.replace(location.origin, '').replace(new RegExp(`^${basePath}`), '/')

        params.to = path

        if (path.match(/^https?:/)) {
          params.target = '_blank'
        }

        return params
      })
    },
    currentResource () {
      if (this.$route.name !== 'resources') {
        return
      }

      return this.$route.params.fragments.reduce((acc, slug, index) => {
        if (index % 2 === 0) {
          return (
            modelSlugMap[acc.associations?.find((assoc) => assoc.slug === slug)?.model_slug] ||
            modelSlugMap[slug]
          )
        } else {
          return acc
        }
      }, {})
    }
  },
  methods: {
    openSearch () {
      this.$Modal.open(Search, {
        placeholder: 'Search...',
        onSelected: (value) => {
          this.$Modal.remove()
        }
      })
    },
    onChangeResource (resource) {
      this.$Drawer.component.setTitle(this.drawerTitle(resource))
    },
    drawerTitle (resource) {
      if (resource) {
        return `${resource.display_name} Settings`
      } else {
        return 'Settings'
      }
    },
    openEditModal () {
      this.$Drawer.open(HeaderEdit, {
        links: this.links
      }, {
        title: 'Header',
        closable: true
      })
    },
    openSettings () {
      this.$Drawer.open(ResourcesSettings, {
        selectedResource: this.currentResource,
        onChangeResource: this.onChangeResource
      }, {
        title: this.drawerTitle(this.currentResource),
        className: 'drawer-no-bottom-padding',
        closable: true
      })
    }
  }
}
</script>

<style lang="scss" scoped>
.header-btn {
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
