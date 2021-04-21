<template>
  <div
    class="row mx-2"
    style="min-height: 74px"
  >
    <div class="col-8">
      <h1
        class="my-3"
      >
        {{ dashboard.title || (isExisting ? '' : 'New dashboard') }}
      </h1>
    </div>
    <div class="col-4 d-flex align-items-center justify-content-end">
      <VButton
        size="large"
        class="bg-white me-2"
        :icon="isEditorOpened ? 'md-close' : 'md-create'"
        @click="toggleEditor"
      >
        {{ isEditorOpened ? 'Close editor' : 'Edit' }}
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
    :style="{ height: 'calc(100vh - 134px)' }"
    class="row border-top m-0"
  >
    <div
      :class="isEditorOpened ? 'col-6 col-lg-9 d-none d-md-block' : 'col-12'"
      style="height: 100%; overflow: scroll"
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
      <DashboardLayout
        ref="layout"
        :variables="variablesData"
        :dashboard="dashboard"
      />
    </div>
    <div
      v-if="isEditorOpened"
      class="col-12 col-md-6 col-lg-3 border-left bg-white p-0"
      style="height: 100%; overflow: scroll"
    >
      <Editor
        :dashboard="dashboard"
        @remove-query="removeQuery"
        @add-query="addQuery"
      />
    </div>
  </div>
</template>

<script>
import Editor from '../components/editor'
import DashboardLayout from '../components/layout'
import DashboardForm from '../components/form'
import VariablesForm from 'queries/components/variables_form'
import api from 'api'

export default {
  name: 'DashboardsNew',
  components: {
    Editor,
    DashboardLayout,
    VariablesForm
  },
  data () {
    return {
      isLoading: false,
      isEditorOpened: false,
      variablesData: {},
      dashboard: {
        tags: [],
        preferences: {
          layout: []
        },
        queries: []
      }
    }
  },
  computed: {
    isExisting () {
      return this.$route.params.id
    },
    variables () {
      return Object.values(this.dashboard.queries.reduce((acc, query) => {
        query.preferences.variables?.forEach((variable) => {
          acc[variable.name] ||= variable
        })

        return acc
      }, {}))
    }
  },
  watch: {
    '$route' (to, from) {
      if (to.name === 'dashboard' || to.name === 'new_dashboard') {
        const isChanged = to.params.id !== this.dashboard.id?.toString()

        if (isChanged) {
          if (to.params.id) {
            this.loadDashboard()
            this.isEditorOpened = false
          } else {
            this.dashboard = { tags: [], preferences: { layout: [] } }
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
      this.isEditorOpened = !this.isEditorOpened
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
      this.isLoading = true

      this.$refs.layout.reload().then(() => {
        this.isLoading = false
      })
    },
    loadDashboard () {
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

<style lang="scss">
</style>
