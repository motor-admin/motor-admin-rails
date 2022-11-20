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
          v-if="canReadReports && reportsLink"
          type="primary"
          :to="{ name: 'reports' }"
          class="header-btn ms-2"
          size="large"
        >
          {{ reportsLink.name }}
        </VButton>
        <VButton
          v-if="$can('read', 'Motor::Form') && formsLink"
          type="primary"
          class="header-btn ms-2"
          size="large"
          :to="{ name: 'forms' }"
        >
          {{ formsLink.name }}
        </VButton>
        <VButton
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
      <Dropdown
        v-if="currentUser?.email"
        trigger="click"
        :placement="'bottom-end'"
        class="ms-2"
      >
        <VButton
          v-if="currentUser"
          type="primary"
          class="header-btn ms-2"
          size="large"
        >
          <Icon
            type="md-contact"
            class="d-block d-sm-none"
            size="large"
          />
          <span class="d-none d-sm-block">
            {{ currentUser.email }}
          </span>
        </VButton>
        <template #list>
          <DropdownMenu>
            <DropdownItem
              v-for="link in linksToRenderForUserDropdown"
              :key="link.name"
            >
              <VButton
                type="text"
                :target="link.target"
                :to="link.to"
                class="p-0 bg-transparent text-dark"
                style="line-height: unset; height: unset"
              >
                {{ link.name }}
              </VButton>
            </DropdownItem>
            <DropdownItem
              :divided="linksToRenderForUserDropdown.length !== 0"
              @click="signOut"
            >
              <Icon
                type="md-exit"
                size="large"
              />
              {{ i18n['sign_out'] }}
            </DropdownItem>
          </DropdownMenu>
        </template>
      </Dropdown>
      <VButton
        v-if="isStandalone && !currentUser?.email"
        type="primary"
        class="header-btn ms-2"
        size="large"
        :to="(basePath + '/sign_in').replace('//', '/')"
      >
        Log In
      </VButton>
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
      <Badge
        v-if="notificationsCount && $can('read', 'Motor::Notification')"
        :count="notificationsCount"
        type="error"
      >
        <VButton
          v-if="$can('read', 'Motor::Notification')"
          type="primary"
          class="ms-2 header-btn"
          size="large"
          :to="{ name: 'notifications' }"
        >
          <Icon
            type="md-notifications"
            size="large"
          />
        </VButton>
      </Badge>
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
import api from 'api'
import Search from './search'
import Guides from './guides'
import LinksEdit from './links_edit'
import { modelSlugMap, modelNameMap } from 'data_resources/scripts/schema'
import { linksStore } from '../scripts/links_store'
import { basePath, adminSettingsPath, isStandalone } from 'utils/scripts/configs'
import { widthLessThan } from 'utils/scripts/dimensions'
import { isShowSettings, toggleSettings } from 'settings/scripts/toggle'
import { openSettingsDrawer } from 'settings/scripts/drawer'
import { currentUser } from 'navigation/scripts/user_store'
import { canVisit } from '../scripts/can_visit'
import { notificationsBus } from 'notes/scripts/subscriptions'

export default {
  name: 'AppHeader',
  data () {
    return {
      notificationsCount: 0
    }
  },
  computed: {
    isShowSettings,
    isStandalone: () => isStandalone,
    basePath: () => basePath,
    currentUser: () => currentUser,
    adminSettingsPath: () => adminSettingsPath,
    reportsLink () {
      return this.links.find((l) => l.link_type === 'reports')
    },
    formsLink () {
      return this.links.find((l) => l.link_type === 'forms')
    },
    canReadReports () {
      return this.$can('read', 'Motor::Query') || this.$can('read', 'Motor::Dashboard') || this.$can('read', 'Motor::Alert')
    },
    isShowCreateButton () {
      return this.$can('create', 'Motor::Query') || this.$can('create', 'Motor::Dashboard') || this.$can('create', 'Motor::Alert') || this.$can('create', 'Motor::Form')
    },
    links () {
      return linksStore
    },
    linksToRenderForUserDropdown () {
      return this.normalizeLinks(this.links.filter((l) => l.link_type === 'user_dropdown'))
    },
    linksToRender () {
      return this.normalizeLinks(this.links.filter((l) => (!l.link_type || l.link_type === 'header') && !['forms', 'reports'].includes(l.link_type)))
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
  mounted () {
    this.loadNotificationsCount()

    notificationsBus.on('notify', (data) => {
      this.loadNotificationsCount()

      Notification.requestPermission().then((result) => {
        const notification = new Notification(data.title, { body: data.description, icon: '/apple-touch-icon.png' })

        return notification
      })
    })

    notificationsBus.on('update', (data) => {
      this.loadNotificationsCount()
    })
  },
  methods: {
    widthLessThan,
    openSettingsDrawer,
    normalizeLinks (links) {
      return links.map((link) => {
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
    loadNotificationsCount () {
      api.get('notifications', {
        params: {
          page: {
            limit: 0,
            offset: 0
          },
          filter: {
            status: 'pending'
          },
          meta: 'count'
        }
      }).then((result) => {
        this.notificationsCount = result.data.meta.count
      })
    },
    signOut () {
      api.delete('session').then(() => {
        document.location.href = '/'
      })
    },
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
:deep(.ivu-badge-count) {
  top: 0
}

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
  .ion-md-contact {
    font-size: 27px;
  }
  .ion-md-close {
    font-size: 20px;
  }
  .ion-md-notifications {
    font-size: 22px;
  }
}
</style>
