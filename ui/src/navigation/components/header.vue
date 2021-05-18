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
      <template v-if="!widthLessThan('sm')">
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
      </template>
    </div>
    <div class="col-2 d-flex justify-content-end align-items-center">
      <VButton
        v-if="isShowSettings"
        type="primary"
        size="large"
        class="header-btn"
        @click="openSettingsDrawer()"
      >
        All Resources
      </VButton>
      <VButton
        v-if="!isShowSettings"
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
        v-if="!isShowSettings"
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
        @click="onSettingsClick"
      >
        <Icon
          :type="isShowSettings ? 'md-close' : 'md-settings'"
          size="large"
        />
      </VButton>
    </div>
  </div>
</template>

<script>
import Search from './search'
import LinksEdit from './links_edit'
import { modelSlugMap, modelNameMap } from 'data_resources/scripts/schema'
import { linksStore } from '../scripts/links_store'
import { basePath } from 'utils/scripts/configs'
import { widthLessThan } from 'utils/scripts/dimensions'
import { isShowSettings, toggleSettings } from 'settings/scripts/toggle'
import { openSettingsDrawer } from 'settings/scripts/drawer'

export default {
  name: 'AppHeader',
  computed: {
    isShowSettings,
    links () {
      return linksStore
    },
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
            modelNameMap[acc.associations?.find((assoc) => assoc.slug === slug)?.model_name] ||
            modelSlugMap[slug]
          )
        } else {
          return acc
        }
      }, {})
    }
  },
  methods: {
    widthLessThan,
    openSettingsDrawer,
    openSearch () {
      this.$Modal.open(Search, {
        placeholder: 'Search...',
        onSelected: (value) => {
          this.$Modal.remove()
        }
      })
    },
    openEditModal () {
      this.$Drawer.open(LinksEdit, {
      }, {
        title: 'Links',
        closable: true
      })
    },
    onSettingsClick () {
      if (this.isShowSettings) {
        return toggleSettings()
      }

      if (['resources'].includes(this.$route.name) && !widthLessThan('sm')) {
        toggleSettings()
      } else {
        openSettingsDrawer({ selectedResource: this.currentResource })
      }
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

  .ion {
    vertical-align: bottom;
  }

  .ion-md-search {
    font-size: 24px;
  }
  .ion-md-add {
    font-size: 26px;
  }
  .ion-md-settings {
    font-size: 22px;
  }
  .ion-md-close {
    font-size: 20px;
  }
}
</style>
