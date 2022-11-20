import { createRouter, createWebHistory } from 'vue-router'
import { basePath } from 'utils/scripts/configs'
import qs from 'qs'

import ResourcesBase from 'data_resources/pages/base'
import QueriesShow from 'queries/pages/show'
import ReportsIndex from 'reports/pages/index'
import FormsIndex from 'custom_forms/pages/index'
import NotificationsIndex from 'notifications/pages/index'
import FormsShow from 'custom_forms/pages/show'
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
    path: '/notifications',
    component: NotificationsIndex,
    name: 'notifications'
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
    path: '/forms/new',
    component: FormsShow,
    name: 'new_form'
  },
  {
    path: '/forms/:id',
    component: FormsShow,
    name: 'form'
  },
  {
    path: '/forms',
    component: FormsIndex,
    name: 'forms'
  },
  {
    path: '/reports/:type?',
    component: ReportsIndex,
    name: 'reports'
  }
]

const router = createRouter({
  history: createWebHistory(basePath),
  parseQuery: qs.parse,
  stringifyQuery: qs.stringify,
  routes
})

export default router
