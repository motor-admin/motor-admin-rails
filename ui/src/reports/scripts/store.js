import { reactive } from 'vue'
import api from 'api'

const itemsStore = reactive([])
const queriesStore = reactive([])
const dashboardsStore = reactive([])
const alertsStore = reactive([])

function normalizeItems (items, type) {
  return items.map((item) => {
    return {
      ...item,
      tags: item.tags.map((tag) => tag.name),
      type
    }
  })
}

function sortItems (items) {
  return items.sort((a, b) => a.updated_at > b.updated_at ? -1 : 1)
}

let queriesRequestLock = null

function queriesRequest () {
  queriesRequestLock ||= api.get('api/queries', {
    params: {
      include: 'tags',
      fields: {
        query: 'id,name,tags,updated_at',
        tags: 'id,name'
      }
    }
  }).finally(() => {
    queriesRequestLock = null
  })

  return queriesRequestLock
}

let dashboardsRequestLock = null

function dashboardsRequest () {
  dashboardsRequestLock ||= api.get('api/dashboards', {
    params: {
      include: 'tags',
      fields: {
        dashboard: 'id,title,tags,updated_at',
        tags: 'id,name'
      }
    }
  }).finally(() => {
    dashboardsRequestLock = null
  })

  return dashboardsRequestLock
}

let alertsRequestLock = null

function alertsRequest () {
  alertsRequestLock ||= api.get('api/alerts', {
    params: {
      include: 'tags',
      fields: {
        alert: 'id,name,tags,is_enabled,updated_at',
        tags: 'id,name'
      }
    }
  }).finally(() => {
    alertsRequestLock = null
  })

  return alertsRequestLock
}

function loadItems () {
  return Promise.all([
    dashboardsRequest(),
    queriesRequest(),
    alertsRequest()
  ]).then(([
    dashboardsResult,
    queriesResult,
    alertsResult
  ]) => {
    const dashboards = normalizeItems(dashboardsResult.data.data, 'dashboard')
    const queries = normalizeItems(queriesResult.data.data, 'query')
    const alerts = normalizeItems(alertsResult.data.data, 'alert')

    queriesStore.splice(0, queriesStore.length, ...sortItems(queries))
    dashboardsStore.splice(0, dashboardsStore.length, ...sortItems(dashboards))
    alertsStore.splice(0, alertsStore.length, ...sortItems(alerts))

    itemsStore.splice(0, itemsStore.length, ...sortItems(dashboardsStore.concat(queriesStore).concat(alertsStore)))
  }).catch((error) => {
    console.error(error)
  })
}

function loadQueries () {
  return queriesRequest().then((queriesResult) => {
    const queries = normalizeItems(queriesResult.data.data, 'query')

    queriesStore.splice(0, queriesStore.length, ...sortItems(queries))

    itemsStore.splice(0, itemsStore.length, ...sortItems(dashboardsStore.concat(queriesStore).concat(alertsStore)))
  }).catch((error) => {
    console.error(error)
  })
}

export {
  itemsStore,
  loadItems,
  loadQueries,
  queriesStore,
  dashboardsStore,
  alertsStore
}
