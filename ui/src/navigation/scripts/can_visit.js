import { dashboardsStore, alertsStore, queriesStore } from 'reports/scripts/store'
import { formsStore } from 'custom_forms/scripts/store'
import { modelSlugMap } from 'data_resources/scripts/schema'
import CanCan from 'utils/scripts/cancan'

function canVisit (route) {
  if (route.name === 'new_query') {
    return CanCan.$can('create', 'Motor::Query')
  } else if (route.name === 'new_form') {
    return CanCan.$can('create', 'Motor::Form')
  } else if (route.name === 'new_alert') {
    return CanCan.$can('create', 'Motor::Alert')
  } else if (route.name === 'new_dashboard') {
    return CanCan.$can('create', 'Motor::Dashboard')
  } else if (route.name === 'resources') {
    return CanCan.$can('create', 'Motor::Query')
  } else if (route.name === 'dashboard') {
    return dashboardsStore.find((e) => e.id.toString() === route.params.id.toString())
  } else if (route.name === 'form') {
    return formsStore.find((e) => e.id.toString() === route.params.id.toString())
  } else if (route.name === 'query') {
    return queriesStore.find((e) => e.id.toString() === route.params.id.toString())
  } else if (route.name === 'alert') {
    return alertsStore.find((e) => e.id.toString() === route.params.id.toString())
  } else if (route.name === 'resources') {
    return !!modelSlugMap[route.params.fragments[0]]
  }
}

export { canVisit }
