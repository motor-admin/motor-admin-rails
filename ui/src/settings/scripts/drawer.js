import ResourcesSettings from 'settings/components/resources_list'
import DynamicDrawer from 'view3/src/plugins/dynamic-drawer'

function onChangeResource (resource) {
  DynamicDrawer.component.setTitle(drawerTitle(resource))
}

function drawerTitle (resource) {
  if (resource) {
    return `${resource.display_name} Settings`
  } else {
    return 'Settings'
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
