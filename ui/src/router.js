import { createRouter, createWebHistory } from 'vue-router'
import { basePath } from 'utils/scripts/configs'

import ResourcesIndex from 'resources/pages/index'
import ResourcesBase from 'resources/pages/base'
import QueriesShow from 'queries/pages/show'
import ReportsIndex from 'reports/pages/index'
import NavigatioHome from 'navigation/pages/home'

const routes = [
  {
    path: '/',
    component: NavigatioHome,
    name: 'home'
  },
  {
    path: '/resources',
    component: ResourcesIndex,
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
    path: '/queries/:id',
    component: QueriesShow,
    name: 'query'
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
