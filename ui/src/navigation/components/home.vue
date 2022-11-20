<template>
  <div
    v-if="widthLessThan('sm')"
    class="mx-2 mx-md-3"
  >
    <div class="d-flex justify-content-between align-items-center">
      <h1 class="mt-3 mb-2">
        {{ i18n['hello_admin'] }}
      </h1>
      <VButton
        v-if="$can('manage', 'all') && $route.name === 'home'"
        :icon="isEdit ? 'md-close' : 'md-create'"
        class="fs-1 bg-transparent"
        type="text"
        @click="isEdit = !isEdit"
      />
    </div>
    <div
      v-if="$route.name === 'home' && !isEdit"
      class="row"
    >
      <LinksSection />
    </div>
  </div>
  <div class="mx-2 mx-md-3 position-relative">
    <h1
      v-if="widthLessThan('sm') && $route.name === 'home' && !filteredHomeItems.length"
      class="mt-3 mb-2"
    >
      {{ i18n['resources'] }}
    </h1>
    <div
      v-else-if="!widthLessThan('sm')"
      class="d-flex justify-content-between align-items-center"
    >
      <h1
        class="mt-3 mb-2"
      >
        {{ i18n['hello_admin'] }}
      </h1>
      <VButton
        v-if="$can('manage', 'all') && $route.name === 'home'"
        :icon="isEdit ? 'md-close' : 'md-create'"
        class="fs-1 bg-transparent"
        type="text"
        @click="isEdit = !isEdit"
      />
    </div>
    <Spin
      v-if="isLoading"
      fix
    />
    <LayoutEditor
      v-if="isEdit"
      :model-value="homepageStore"
      style="max-width: 450px; margin: auto;"
      @submit="submitLayout"
    />
    <div
      v-else-if="$route.name === 'home'"
    >
      <Dashboard
        v-for="item in filteredHomeItems"
        :key="item.id"
        :dashboard-id="item.id"
      />
    </div>
    <div
      v-if="!isEdit && (filteredHomeItems.length === 0 || $route.name === 'data_home')"
      class="row"
    >
      <div
        v-for="resource in visibleResources"
        :key="resource.slug"
        class="col-12 col-md-6 col-lg-4 col-xl-3"
      >
        <RouterLink
          class="ivu-card ivu-card-bordered my-2"
          :to="{ name: 'resources', params: { fragments: [resource.slug] }}"
        >
          <div class="ivu-card-body">
            <p class="fs-4 fw-bold text-dark">
              {{ resource.display_name.replace('/', '\u200B/') }}
            </p>
          </div>
        </RouterLink>
      </div>
      <div
        v-if="!schema.length && databaseSettingsPath"
        class="text-center mb-4"
      >
        <VButton
          icon="md-add"
          size="large"
          :to="databaseSettingsPath"
        >
          {{ i18n.add_database }}
        </VButton>
      </div>
    </div>
    <div
      v-if="!isEdit"
      class="text-center"
      style="bottom: 0"
    >
      <a
        :href="isStandalone ? 'https://github.com/motor-admin/motor-admin' : 'https://github.com/motor-admin/motor-admin-rails'"
        target="_blank"
      >Motor Admin v{{ version }}</a>
    </div>
  </div>
</template>

<script>
import api from 'api'
import LinksSection from 'navigation/components/links_section'
import LayoutEditor from './layout_editor'
import Dashboard from './dashboard'
import { widthLessThan } from 'utils/scripts/dimensions'
import { schema } from 'data_resources/scripts/schema'
import { homepageStore } from '../scripts/homepage_store'
import { version, isStandalone, adminSettingsPath } from 'utils/scripts/configs'
import { currentUser } from 'navigation/scripts/user_store'

export default {
  name: 'Home',
  components: {
    LinksSection,
    LayoutEditor,
    Dashboard
  },
  data () {
    return {
      isEdit: false,
      isLoading: false
    }
  },
  computed: {
    version: () => version,
    schema: () => schema,
    isStandalone: () => isStandalone,
    currentUser: () => currentUser,
    homepageStore () {
      return homepageStore
    },
    filteredHomeItems () {
      return homepageStore.filter((item) => {
        return !item.conditions || item.conditions.every((cond) => {
          return [currentUser[cond.field === 'role' ? 'role_names' : cond.field]].flat().includes(cond.value)
        })
      })
    },
    databaseSettingsPath () {
      return adminSettingsPath?.replace('general', 'database')
    },
    visibleResources () {
      return schema.filter((model) => model.visible)
    }
  },
  methods: {
    widthLessThan,
    submitLayout (data) {
      this.isLoading = true

      api.post('configs', {
        key: 'homepage.layout',
        value: data
      }).then((result) => {
        homepageStore.splice(0, homepageStore.length, ...result.data.data.value)

        this.isEdit = false
        this.isLoading = false
      }).catch((error) => {
        console.error(error)

        this.$Message.error(this.i18n.unable_to_submit_form)
        this.isLoading = false
      })
    }
  }
}
</script>
