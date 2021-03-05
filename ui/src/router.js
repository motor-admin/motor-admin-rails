import { createRouter, createWebHistory } from 'vue-router'
import { basePath } from 'utils/scripts/configs'

import ResourcesBase from 'resources/pages/base'

const routes = [
  {
    path: '/',
    component: ResourcesBase,
    name: 'dashboard'
  },
  {
    path: '/resources/:fragments+',
    component: ResourcesBase,
    name: 'resources'
  }
]

const router = createRouter({
  history: createWebHistory(basePath),
  routes
})

export default router
