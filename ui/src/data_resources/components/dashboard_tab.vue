<template>
  <div>
    <Spin
      v-if="isLoading"
      fix
    />
    <template v-else-if="dashboard.id">
      <VariablesForm
        v-model:data="dataVariables"
        :variables="variablesToRender"
        class="mx-2 pb-3"
        @submit="reload"
      />
      <DashboardLayout
        ref="layout"
        :variables="dataVariables"
        class="mx-1"
        :dashboard="dashboard"
      />
    </template>
  </div>
</template>

<script>
import VariablesForm from 'queries/components/variables_form'
import DashboardLayout from 'dashboards/components/layout'
import api from 'api'

export default {
  name: 'DashboardTab',
  components: {
    VariablesForm,
    DashboardLayout
  },
  props: {
    variables: {
      type: Object,
      required: false,
      default: () => ({})
    },
    tab: {
      type: Object,
      required: true
    }
  },
  data () {
    return {
      isLoading: true,
      dataVariables: { ...this.variables },
      dashboard: {}
    }
  },
  computed: {
    dashboardId () {
      return this.tab.preferences.dashboard_id
    },
    variablesToRender () {
      return Object.values(this.dashboard.queries.reduce((acc, query) => {
        query.preferences.variables?.forEach((variable) => {
          acc[variable.name] ||= variable
        })

        return acc
      }, {})).filter((variable) => !this.variables[variable.name])
    },
    style () {
      if (this.isLoading || !this.showVariablesForm) {
        return 'height: 100%'
      } else {
        return 'height: calc(100% - 84px)'
      }
    }
  },
  mounted () {
    this.loadDashboard()
  },
  methods: {
    reload () {
      this.$nextTick(() => {
        this.$refs.layout.reload()
      })
    },
    assignDefaultVariables () {
      this.variablesToRender.forEach((variable) => {
        this.dataVariables[variable.name] ||= variable.default_value
      })
    },
    loadDashboard () {
      return api.get(`dashboards/${this.dashboardId}`, {
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

        if (error.response.data?.errors) {
          this.$Message.error(error.response.data.errors.join('\n'))
        }
      }).finally(() => {
        this.isLoading = false
      })
    }
  }
}
</script>
