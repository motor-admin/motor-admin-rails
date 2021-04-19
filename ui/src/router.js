import { createRouter, createWebHistory } from 'vue-router'
import { basePath } from 'utils/scripts/configs'
import qs from 'qs'

import ResourcesBase from 'data_resources/pages/base'
import QueriesShow from 'queries/pages/show'
import AllResourcesIndex from 'all_resources/pages/index'
import DashboardsShow from 'dashboards/pages/show'
import AlertsShow from 'alerts/pages/show'

const routes = [
  {
    path: '/',
    component: ResourcesBase,
    name: 'home'
  },
  {
    path: '/data',
    component: ResourcesBase,
    name: 'data_home'
  },
  {
    path: '/data/:fragments+',
    component: ResourcesBase,
    name: 'resources'
  },
  {
    path: '/queries/new',
    component: QueriesShow,
    name: 'new_query'
  },
  {
    path: '/dashboards/:id',
    component: DashboardsShow,
    name: 'dashboard'
  },
  {
    path: '/dashboards/new',
    component: DashboardsShow,
    name: 'new_dashboard'
  },
  {
    path: '/queries/:id',
    component: QueriesShow,
    name: 'query'
  },
  {
    path: '/alerts/new',
    component: AlertsShow,
    name: 'new_alert'
  },
  {
    path: '/alerts/:id',
    component: AlertsShow,
    name: 'alert'
  },
  {
    path: '/browse',
    component: AllResourcesIndex,
    name: 'all_resources'
  },
  {
    path: '/dashboards',
    component: AllResourcesIndex,
    name: 'dashboards'
  },
  {
    path: '/alerts',
    component: AllResourcesIndex,
    name: 'alerts'
  },
  {
    path: '/queries',
    component: AllResourcesIndex,
    name: 'queries'
  },
  {
    path: '/tables',
    component: AllResourcesIndex,
    name: 'tables'
  },
  {
    path: '/forms',
    component: AllResourcesIndex,
    name: 'forms'
  }
]

const router = createRouter({
  history: createWebHistory(basePath),
  parseQuery: qs.parse,
  stringifyQuery: qs.stringify,
  routes
})

export default router
