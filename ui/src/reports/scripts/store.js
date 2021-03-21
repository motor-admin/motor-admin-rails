import { reactive } from 'vue'
import api from 'api'

const itemsStore = reactive([])

function normalizeItems (items, type) {
  return items.map((item) => {
    item.tags = item.tags.map((tag) => tag.name)
    item.type = type

    return item
  })
}

function loadItems () {
  const queriesRequest =
    api.get('api/queries', {
      params: {
        include: 'tags',
        fields: {
          query: 'id,name,tags',
          tags: 'id,name'
        }
      }
    })

  const dashboardsRequest =
    api.get('api/dashboards', {
      params: {
        include: 'tags',
        fields: {
          dashboard: 'title,tags',
          tags: 'name'
        }
      }
    })

  return Promise.all([dashboardsRequest, queriesRequest]).then(([dashboardsResult, queriesResult]) => {
    const dashboards = normalizeItems(dashboardsResult.data.data, 'dashboard')
    const queries = normalizeItems(queriesResult.data.data, 'query')

    itemsStore.splice(0, itemsStore.length, ...dashboards.concat(queries))
  }).catch((error) => {
    console.error(error)
  })
}

export { itemsStore, loadItems }
