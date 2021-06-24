import ResourcesSettings from 'settings/components/resources_list'
import DynamicDrawer from 'view3/src/plugins/dynamic-drawer'
import { i18nDict } from 'utils/scripts/configs'

function onChangeResource (resource) {
  DynamicDrawer.component.setTitle(drawerTitle(resource))
}

function drawerTitle (resource) {
  if (resource) {
    return i18nDict.resource_settings.replace('%{resource}', resource.display_name)
  } else {
    return i18nDict.settings
  }
}

function openSettingsDrawer (props = {}) {
  DynamicDrawer.open(ResourcesSettings, {
    onChangeResource,
    ...props
  }, {
    title: drawerTitle(props.selectedResource),
    className: 'drawer-no-bottom-padding drawer-no-top-padding',
    closable: true
  })
}

export { openSettingsDrawer }
