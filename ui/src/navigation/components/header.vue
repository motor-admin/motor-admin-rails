<template>
  <div class="ivu-menu ivu-menu-primary ivu-menu-horizontal row m-0">
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
          v-if="canReadReports"
          type="primary"
          :to="{ name: 'reports' }"
          class="header-btn ms-2"
          size="large"
        >
          {{ i18n['reports'] }}
        </VButton>
        <VButton
          v-if="$can('read', 'Motor::Form')"
          type="primary"
          class="header-btn ms-2"
          size="large"
          :to="{ name: 'forms' }"
        >
          {{ i18n['forms'] }}
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
          v-if="$can('manage', 'Motor::Config')"
          type="primary"
          class="ms-2 add-item-btn"
          icon="md-add"
          @click="openEditModal"
        />
      </template>
    </div>
    <div class="col-2 d-flex justify-content-end align-items-center">
      <VButton
        v-if="!isShowSettings && currentUser.showHelp"
        type="primary"
        size="large"
        class="header-btn"
        @click="openGuides"
      >
        <Icon
          type="md-help"
          size="large"
        />
      </VButton>
      <VButton
        v-if="!isShowSettings && adminSettingsPath && $can('manage', 'all')"
        type="primary"
        size="large"
        class="header-btn"
        :to="adminSettingsPath"
      >
        <Icon
          type="md-person-add"
          size="large"
        />
      </VButton>
      <VButton
        v-if="!isShowSettings"
        type="primary"
        size="large"
        class="ms-2 header-btn"
        @click="openSearch"
      >
        <Icon
          type="md-search"
          size="large"
        />
      </VButton>
      <Dropdown
        v-if="!isShowSettings && isShowCreateButton"
        trigger="click"
        :placement="$can('manage', 'all') ? 'bottom' : 'bottom-end'"
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
            <DropdownItem
              v-if="$can('create', 'Motor::Query')"
              @click="$router.push({ name: 'new_query' })"
            >
              {{ i18n['add_query'] }}
            </DropdownItem>
            <DropdownItem
              v-if="$can('create', 'Motor::Dashboard')"
              @click="$router.push({ name: 'new_dashboard' })"
            >
              {{ i18n['add_dashboard'] }}
            </DropdownItem>
            <DropdownItem
              v-if="$can('create', 'Motor::Form')"
              @click="$router.push({ name: 'new_form'})"
            >
              {{ i18n['add_form'] }}
            </DropdownItem>
            <DropdownItem
              v-if="$can('create', 'Motor::Alert')"
              @click="$router.push({ name: 'new_alert' })"
            >
              {{ i18n['add_alert'] }}
            </DropdownItem>
          </DropdownMenu>
        </template>
      </Dropdown>
      <VButton
        v-if="$can('manage', 'all')"
        type="primary"
        class="ms-2 header-btn"
        size="large"
        @click="onSettingsClick"
      >
        <Icon
          :type="isShowSettings ? 'md-close' : 'md-settings'"
          size="large"
        />
        <span
          v-if="isShowSettings"
          style="vertical-align: middle"
        >{{ i18n['close_settings'] }}</span>
      </VButton>
    </div>
  </div>
</template>

<script>
import Search from './search'
import Guides from './guides'
import LinksEdit from './links_edit'
import { modelSlugMap, modelNameMap } from 'data_resources/scripts/schema'
import { linksStore } from '../scripts/links_store'
import { basePath, adminSettingsPath } from 'utils/scripts/configs'
import { widthLessThan } from 'utils/scripts/dimensions'
import { isShowSettings, toggleSettings } from 'settings/scripts/toggle'
import { openSettingsDrawer } from 'settings/scripts/drawer'
import { currentUser } from 'navigation/scripts/user_store'
import { canVisit } from '../scripts/can_visit'

export default {
  name: 'AppHeader',
  computed: {
    isShowSettings,
    currentUser: () => currentUser,
    adminSettingsPath: () => adminSettingsPath,
    canReadReports () {
      return this.$can('read', 'Motor::Query') || this.$can('read', 'Motor::Dashboard') || this.$can('read', 'Motor::Alert')
    },
    isShowCreateButton () {
      return this.$can('create', 'Motor::Query') || this.$can('create', 'Motor::Dashboard') || this.$can('create', 'Motor::Alert') || this.$can('create', 'Motor::Form')
    },
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

          return params
        }

        const resolvedRoute = this.$router.resolve({ path }, this.$route)

        if (resolvedRoute?.name) {
          if (canVisit(resolvedRoute)) {
            return params
          } else {
            return null
          }
        } else {
          return params
        }
      }).filter(Boolean)
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
        placeholder: this.i18n.search_placeholder,
        onSelected: (value) => {
          this.$Modal.remove()
        }
      })
    },
    openGuides () {
      this.$Modal.open(Guides, {
      }, {
        closable: true,
        className: 'modal-size-large'
      })
    },
    openEditModal () {
      this.$Drawer.open(LinksEdit, {
      }, {
        title: this.i18n.links,
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
    vertical-align: sub;
    line-height: 1;
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
  .ion-md-help {
    font-size: 24px;
  }
  .ion-md-person-add {
    font-size: 26px;
  }
  .ion-md-close {
    font-size: 20px;
  }
}
</style>
