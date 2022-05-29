<template>
  <div
    class="row mx-0 mx-md-2"
    style="min-height: 74px"
  >
    <div class="col-8">
      <div class="row">
        <div class="col d-flex align-items-center">
          <h1
            class="my-3 overflow-hidden text-truncate"
          >
            {{ dashboard.title || cachedDashboardTitle || (isExisting ? '' : i18n['new_dashboard']) }}
          </h1>
        </div>
        <UnsavedChanges
          ref="unsavedChanges"
          :key="dashboard.id || 'new'"
          v-model="dashboard"
          :storage-key="`dashboard:${$route.params.id || 'new'}`"
          class="col d-none d-xl-flex"
        />
      </div>
    </div>
    <div class="col-4 d-flex align-items-center justify-content-end">
      <Dropdown
        trigger="click"
        class="me-2"
        :placement="'bottom-end'"
      >
        <VButton
          size="large"
          icon="md-timer"
          :type="dashboard.preferences.autorefresh_interval ? 'primary' : 'default'"
          class="bg-white"
          :ghost="!!dashboard.preferences.autorefresh_interval"
        />
        <template #list>
          <DropdownMenu>
            <DropdownItem
              v-for="option in refreshTimerOptions"
              :key="option.value"
              @click="updateTimerValue(option.value)"
            >
              {{ option.title }}
            </DropdownItem>
          </DropdownMenu>
        </template>
      </Dropdown>
      <VButton
        v-if="variables.length && isCanEdit"
        size="large"
        class="me-2 md-icon-only d-none d-sm-block"
        :icon="isVariableSettingsOpened ? 'md-close' : 'md-flask'"
        @click="toggleVariablesSettings"
      >
        {{ isVariableSettingsOpened ? i18n['close_variables'] : i18n['variables'] }}
      </VButton>
      <VButton
        v-if="isCanEdit"
        size="large"
        class="bg-white me-2 md-icon-only"
        :icon="isEditorOpened ? 'md-close' : 'md-create'"
        @click="toggleEditor"
      >
        {{ isEditorOpened ? i18n['close_editor'] : i18n['edit'] }}
      </VButton>
      <VButton
        v-if="isExisting && $can('create', 'Motor::Dashboard')"
        size="large"
        class="bg-white me-2 d-none d-sm-block"
        @click="saveAsNew"
      >
        {{ i18n['save_as_new'] }}
      </VButton>
      <VButton
        v-if="isCanEdit"
        size="large"
        class="bg-white me-2"
        ghost
        type="primary"
        @click="save"
      >
        {{ i18n['save'] }}
      </VButton>
      <VButton
        size="large"
        type="primary"
        :loading="isLoading"
        class="d-none d-sm-block"
        icon="md-refresh"
        @click="refresh"
      />
    </div>
  </div>
  <div
    :style="{ height: isSettingsOpened ? 'calc(var(--vh, 100vh) - 134px)' : '100%' }"
    class="row border-top m-0"
  >
    <div
      :class="isSettingsOpened ? 'col-6 col-lg-9 d-none d-md-block' : 'col-12'"
      class="position-relative"
      :style="{ height: '100%', overflowY: isSettingsOpened ? 'auto' : 'unset' }"
    >
      <div
        v-if="variables.length"
        class="pb-2 px-2"
      >
        <VariablesForm
          v-model:data="variablesData"
          :variables="variables"
          @submit="refresh"
        />
      </div>
      <Spin
        v-if="isDashboardLoading"
        fix
        style="height: calc(var(--vh, 100vh) - 134px)"
      />
      <DashboardLayout
        ref="layout"
        class="pt-1"
        :variables="variablesData"
        :dashboard="dashboard"
      />
    </div>
    <div
      v-if="isSettingsOpened"
      class="col-12 col-md-6 col-lg-3 border-left bg-white p-0"
      style="height: 100%; overflowY: auto"
    >
      <Editor
        v-if="isEditorOpened"
        :dashboard="dashboard"
        @remove-query="removeQuery"
        @click-item="$refs.layout.scrollInto"
        @move="$refs.layout.scrollInto"
        @add-query="addQuery"
      />
      <div v-if="isVariableSettingsOpened">
        <div :style="{ minHeight: 'calc(var(--vh, 100vh) - 203px)' }">
          <Card
            v-for="variable in variables"
            :key="variable.name"
            class="m-2"
          >
            <div class="fw-bold mb-3">
              {{ variable.display_name }}
            </div>
            <VariableSettings
              :variable="variable"
              @update:variable="assignVariablePreferences"
            />
          </Card>
        </div>
        <div class="footer p-2">
          <VButton
            long
            type="default"
            icon="md-close"
            @click="toggleVariablesSettings"
          >
            {{ i18n.close }}
          </VButton>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import Editor from '../components/editor'
import DashboardLayout from '../components/layout'
import DashboardForm from '../components/form'
import VariablesForm from 'queries/components/variables_form'
import VariableSettings from 'queries/components/variable_settings'
import { dashboardsStore } from 'reports/scripts/store'
import UnsavedChanges from 'utils/components/unsaved_changes'
import api from 'api'

export default {
  name: 'DashboardsNew',
  components: {
    Editor,
    DashboardLayout,
    VariablesForm,
    VariableSettings,
    UnsavedChanges
  },
  data () {
    return {
      isLoading: false,
      isDashboardLoading: false,
      isVariableSettingsOpened: false,
      isEditorOpened: false,
      variablesData: {},
      dashboard: {
        tags: [],
        preferences: {
          layout: [],
          variables: []
        },
        queries: []
      }
    }
  },
  computed: {
    isExisting () {
      return this.$route.params.id
    },
    refreshTimerOptions () {
      return [
        { title: this.i18n.every_5_seconds, value: 5 * 1000 },
        { title: this.i18n.every_30_seconds, value: 30 * 1000 },
        { title: this.i18n.every_minute, value: 60 * 1000 },
        { title: this.i18n.every_5_minutes, value: 5 * 60 * 1000 },
        { title: this.i18n.do_not_refresh, value: 0 }
      ]
    },
    isCanEdit () {
      return this.dashboard.id ? this.$can('edit', 'Motor::Dashboard', this.dashboard) : this.$can('create', 'Motor::Dashboard')
    },
    isSettingsOpened () {
      return this.isEditorOpened || this.isVariableSettingsOpened
    },
    cachedDashboardTitle () {
      return dashboardsStore.find((e) => e.id.toString() === this.$route.params?.id)?.title
    },
    variables () {
      return Object.values(this.dashboard.queries.reduce((acc, q) => {
        q.preferences.variables?.forEach((variable) => {
          acc[variable.name] ||= this.dashboard.preferences.variables?.find((v) => v.name === variable.name) || variable
        })

        return acc
      }, {}))
    },
    queryParamsVariables () {
      return this.$route.query || {}
    },
    defaultVariablesData () {
      return this.variables.reduce((acc, variable) => {
        acc[variable.name] = variable.default_value ?? ''

        return acc
      }, {})
    }
  },
  watch: {
    '$route' (to, from) {
      if (to.name === 'dashboard' || to.name === 'new_dashboard') {
        const isChanged = to.params.id !== this.dashboard.id?.toString()

        if (isChanged) {
          this.dashboard = { tags: [], preferences: { layout: [], variables: [] }, queries: [] }

          if (to.params.id) {
            this.loadDashboard()
            this.isEditorOpened = false
          } else {
            this.isEditorOpened = true
          }
        } else if (JSON.stringify(to.query) !== JSON.stringify(from.query)) {
          this.assignVariablesData()
          this.refresh()
        }
      }
    }
  },
  mounted () {
    if (this.$route.params.id) {
      this.loadDashboard().then(() => {
        this.setAutorefreshInterval()
      })
    } else {
      this.isEditorOpened = true
    }
  },
  beforeUnmount () {
    if (this.timer) {
      clearInterval(this.timer)
    }
  },
  methods: {
    maybeUpdateVariablesQueryParams () {
      if (Object.keys(this.defaultVariablesData).length) {
        const nonDefaultVariablesData = Object.keys(this.defaultVariablesData).reduce((acc, key) => {
          if ((this.variablesData[key] ?? '').toString() !== (this.defaultVariablesData[key] ?? '').toString()) {
            acc[key] = this.variablesData[key]
          }

          return acc
        }, {})

        if (Object.keys(nonDefaultVariablesData).length) {
          this.$router.replace({ query: { ...nonDefaultVariablesData } })
        } else if (Object.keys(this.queryParamsVariables).length) {
          this.$router.replace({ query: null })
        }
      }
    },
    toggleEditor () {
      this.isVariableSettingsOpened = false
      this.isEditorOpened = !this.isEditorOpened
    },
    toggleVariablesSettings () {
      this.isEditorOpened = false
      this.isVariableSettingsOpened = !this.isVariableSettingsOpened
    },
    assignVariablePreferences (variable) {
      if (!this.dashboard.preferences.variables?.find((v) => v.name === variable.name)) {
        this.dashboard.preferences.variables ||= []
        this.dashboard.preferences.variables.push(variable)
      }
    },
    removeQuery (queryId) {
      const index = this.dashboard.queries.findIndex((query) => query.id === queryId)

      this.dashboard.queries.splice(index, 1)
    },
    assignVariablesData () {
      this.variablesData = { ...this.defaultVariablesData, ...this.queryParamsVariables }
    },
    addQuery (queryId) {
      api.get(`queries/${queryId}`, {
        params: {
          fields: {
            query: 'id,name,preferences'
          }
        }
      }).then((result) => {
        this.dashboard.queries.push(result.data.data)
      }).catch((error) => {
        console.error(error)
      })
    },
    refresh (withLoading = true) {
      this.maybeUpdateVariablesQueryParams()

      this.$nextTick(() => {
        this.isLoading = true

        this.$refs.layout.reload(withLoading).then(() => {
          this.isLoading = false
        })
      })
    },
    loadDashboard () {
      this.isDashboardLoading = true

      return api.get(`dashboards/${this.$route.params.id}`, {
        params: {
          include: 'tags,queries',
          fields: {
            queries: 'id,name,preferences'
          }
        }
      }).then((result) => {
        this.dashboard = result.data.data
        this.assignVariablesData()
      }).catch((error) => {
        if (error.response?.data?.errors) {
          this.$Message.error(error.response.data.errors.join('\n'))
        } else {
          this.$Message.error(error.message)
        }
      }).finally(() => {
        this.isDashboardLoading = false
      })
    },
    onSuccess (dashboard) {
      this.$refs.unsavedChanges.resetWithDefaultValue(dashboard)
      this.dashboard = dashboard

      this.$Modal.remove()
      this.$Message.info(this.i18n.dashboard_has_been_saved)

      this.$router.push({ name: 'dashboard', params: { id: dashboard.id } })

      this.isEditorOpened = false
    },
    saveAsNew () {
      this.$Modal.open(DashboardForm, {
        board: {
          title: this.dashboard.title,
          description: this.dashboard.description,
          tags: this.dashboard.tags.map((tag) => tag.name),
          preferences: this.dashboard.preferences
        },
        onSuccess: (dashboard) => {
          this.onSuccess(dashboard)
        }
      }, {
        title: this.i18n.save_dashboard,
        closable: true
      })
    },
    save () {
      this.$Modal.open(DashboardForm, {
        board: {
          id: this.dashboard.id,
          title: this.dashboard.title,
          description: this.dashboard.description,
          tags: this.dashboard.tags.map((tag) => tag.name),
          preferences: this.dashboard.preferences
        },
        onSuccess: (dashboard) => {
          this.onSuccess(dashboard)
        }
      }, {
        title: this.i18n.save_dashboard,
        closable: true
      })
    },
    updateTimerValue (value) {
      if (this.timer) {
        clearInterval(this.timer)
      }

      this.dashboard.preferences.autorefresh_interval = value

      this.setAutorefreshInterval()
    },
    setAutorefreshInterval () {
      if (this.dashboard.preferences.autorefresh_interval) {
        this.timer = setInterval(() => this.refresh(false), this.dashboard.preferences.autorefresh_interval)
      }
    }
  }
}
</script>

<style lang="scss" scoped>
.footer {
  width: 100%;
  position: sticky;
  bottom: 0;
  left: 0;
  border-top: 1px solid #e8e8e8;
  padding-top: 8px;
  text-align: right;
  background: #fff;
}
</style>
