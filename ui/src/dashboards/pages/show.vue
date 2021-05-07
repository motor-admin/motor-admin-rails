<template>
  <div
    class="row mx-0 mx-md-2"
    style="min-height: 74px"
  >
    <div class="col-7 col-md-8 d-flex align-items-center">
      <h1
        class="my-3 overflow-hidden text-truncate"
      >
        {{ dashboard.title || (isExisting ? '' : 'New dashboard') }}
      </h1>
    </div>
    <div class="col-5 col-md-4 d-flex align-items-center justify-content-end">
      <VButton
        size="large"
        class="bg-white me-2 md-icon-only"
        :icon="isEditorOpened ? 'md-close' : 'md-create'"
        @click="toggleEditor"
      >
        {{ isEditorOpened ? 'Close editor' : 'Edit' }}
      </VButton>
      <VButton
        v-if="variables.length"
        size="large"
        class="me-2 md-icon-only"
        :icon="isVariableSettingsOpened ? 'md-close' : 'md-flask'"
        @click="toggleVariablesSettings"
      >
        {{ isVariableSettingsOpened ? 'Close Variables' : 'Variables' }}
      </VButton>
      <VButton
        size="large"
        class="bg-white me-2"
        ghost
        type="primary"
        @click="save"
      >
        Save
      </VButton>
      <VButton
        size="large"
        type="primary"
        :loading="isLoading"
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
      :style="{ height: '100%', overflow: isSettingsOpened ? 'scroll' : 'unset' }"
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
      style="height: 100%; overflow: scroll"
    >
      <Editor
        v-if="isEditorOpened"
        :dashboard="dashboard"
        @remove-query="removeQuery"
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
            Close
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
import api from 'api'

export default {
  name: 'DashboardsNew',
  components: {
    Editor,
    DashboardLayout,
    VariablesForm,
    VariableSettings
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
    isSettingsOpened () {
      return this.isEditorOpened || this.isVariableSettingsOpened
    },
    variables () {
      return this.dashboard.queries.reduce((acc, query) => {
        query.preferences.variables?.forEach((variable) => {
          if (!acc.find((v) => v.name === variable.name)) {
            acc.push(variable)
          }
        })

        return acc
      }, [...(this.dashboard.preferences.variables || [])])
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
        }
      }
    }
  },
  mounted () {
    if (this.$route.params.id) {
      this.loadDashboard()
    } else {
      this.isEditorOpened = true
    }
  },
  methods: {
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
    assignDefaultVariables () {
      this.variables.forEach((variable) => {
        this.variablesData[variable.name] ||= variable.default_value
      })
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
    refresh () {
      this.$nextTick(() => {
        this.isLoading = true

        this.$refs.layout.reload().then(() => {
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
        this.assignDefaultVariables()
      }).catch((error) => {
        console.error(error)
      }).finally(() => {
        this.isDashboardLoading = false
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
          Object.assign(this.dashboard, dashboard)

          this.$Modal.remove()
          this.$Message.info('Dashboard has been saved!')

          this.$router.push({ name: 'dashboard', params: { id: dashboard.id } })

          this.isEditorOpened = false
        }
      }, {
        title: 'Save dashboard',
        closable: true
      })
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
