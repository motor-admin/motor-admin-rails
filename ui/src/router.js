import { createRouter, createWebHistory } from 'vue-router'
import { basePath } from 'utils/scripts/configs'

import ResourcesBase from 'resources/pages/base'
import QueriesShow from 'queries/pages/show'
import ReportsIndex from 'reports/pages/index'
import DashboardsShow from 'dashboards/pages/show'
import NavigatioHome from 'navigation/pages/home'
import AlertsShow from 'alerts/pages/show'

const routes = [
  {
    path: '/',
    component: NavigatioHome,
    name: 'home'
  },
  {
    path: '/resources',
    component: ResourcesBase,
    name: 'resources_home'
  },
  {
    path: '/resources/:fragments+',
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
    path: '/reports/:type?',
    component: ReportsIndex,
    name: 'reports'
  }
]

const router = createRouter({
  history: createWebHistory(basePath),
  routes
})

export default router
