const appNode = document.getElementById('app')

const basePath = appNode.getAttribute('data-base-path')
const cablePath = appNode.getAttribute('data-cable-path')
const adminSettingsPath = appNode.getAttribute('data-admin-settings-path')
const version = appNode.getAttribute('data-version')
const isActiveStorageDirectUploadsEnabled = JSON.parse(appNode.getAttribute('data-active-storage-direct-uploads-enabled'))
const canCanRules = JSON.parse(appNode.getAttribute('data-current-rules'))
const databaseNames = JSON.parse(appNode.getAttribute('data-databases'))
const i18nDict = JSON.parse(appNode.getAttribute('data-i18n'))
const isStandalone = !!adminSettingsPath

export {
  version,
  basePath,
  cablePath,
  adminSettingsPath,
  canCanRules,
  i18nDict,
  isStandalone,
  isActiveStorageDirectUploadsEnabled,
  databaseNames
}
