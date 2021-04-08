import { reactive } from 'vue'
import api from 'api'

const itemsStore = reactive([])
const queriesStore = reactive([])
const dashboardsStore = reactive([])

function normalizeItems (items, type) {
  return items.map((item) => {
    item.tags = item.tags.map((tag) => tag.name)
    item.type = type

    return item
  })
}

function sortItems (items) {
  return items.sort((a, b) => a.updated_at > b.updated_at ? -1 : 1)
}

function loadItems () {
  const queriesRequest =
    api.get('api/queries', {
      params: {
        include: 'tags',
        fields: {
          query: 'id,name,tags,updated_at',
          tags: 'id,name'
        }
      }
    })

  const dashboardsRequest =
    api.get('api/dashboards', {
      params: {
        include: 'tags',
        fields: {
          dashboard: 'id,title,tags,updated_at',
          tags: 'id,name'
        }
      }
    })

  return Promise.all([dashboardsRequest, queriesRequest]).then(([dashboardsResult, queriesResult]) => {
    const dashboards = normalizeItems(dashboardsResult.data.data, 'dashboard')
    const queries = normalizeItems(queriesResult.data.data, 'query')

    itemsStore.splice(0, itemsStore.length, ...sortItems(dashboards.concat(queries)))
    queriesStore.splice(0, queriesStore.length, ...sortItems(queries))
    dashboardsStore.splice(0, dashboardsStore.length, ...sortItems(dashboards))
  }).catch((error) => {
    console.error(error)
  })
}

export { itemsStore, loadItems, queriesStore, dashboardsStore }
