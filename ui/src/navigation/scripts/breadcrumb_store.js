import { reactive } from 'vue'

const breadcrumbStore = reactive({})

function assignBreadcrumbLabel (resourceName, resourceId, label) {
  breadcrumbStore[resourceName] ||= {}
  breadcrumbStore[resourceName][resourceId] = label
}

export {
  breadcrumbStore,
  assignBreadcrumbLabel
}
