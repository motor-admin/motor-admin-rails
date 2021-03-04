import { createRouter, createWebHistory } from 'vue-router'

import ResourcesIndex from 'resources/pages/index'

const basePath = document.getElementById('app').dataset['base-path']

const routes = [
  {
    path: '/',
    component: ResourcesIndex,
    name: 'resources'
  }
]

const router = createRouter({
  history: createWebHistory(basePath),
  routes
})

export default router
