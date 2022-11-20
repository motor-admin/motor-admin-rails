<template>
  <DashboardLayout
    v-if="dashboard"
    ref="dashboardLayout"
    :dashboard="dashboard"
  />
  <Spin
    v-if="isLoading"
    fix
  />
</template>

<script>
import api from 'api'
import DashboardLayout from 'dashboards/components/layout'

export default {
  name: 'HomeDashboard',
  components: {
    DashboardLayout
  },
  props: {
    dashboardId: {
      type: [String, Number],
      required: true
    }
  },
  data () {
    return {
      dashboard: null,
      isLoading: false
    }
  },
  beforeUnmount () {
    if (this.timer) {
      clearInterval(this.timer)
    }
  },
  mounted () {
    this.loadDashboard().then(() => {
      this.setAutorefreshInterval()
    })
  },
  methods: {
    setAutorefreshInterval () {
      if (this.dashboard.preferences.autorefresh_interval) {
        this.timer = setInterval(() => this.refresh(false), this.dashboard.preferences.autorefresh_interval)
      }
    },
    refresh () {
      this.$refs.dashboardLayout.reload(false)
    },
    loadDashboard () {
      this.isLoading = true

      return api.get(`dashboards/${this.dashboardId}`, {
        params: {
          include: 'tags,queries',
          fields: {
            queries: 'id,name,preferences'
          }
        }
      }).then((result) => {
        this.dashboard = result.data.data
      }).catch((error) => {
        if (error.response?.data?.errors) {
          this.$Message.error(error.response.data.errors.join('\n'))
        } else {
          this.$Message.error(error.message)
        }
      }).finally(() => {
        this.isLoading = false
      })
    }
  }
}
</script>
