const appNode = document.getElementById('app')

const basePath = appNode.getAttribute('data-base-path')
const adminSettingsPath = appNode.getAttribute('data-admin-settings-path')
const version = appNode.getAttribute('data-version')
const canCanRules = JSON.parse(appNode.getAttribute('data-current-rules'))
const i18nDict = JSON.parse(appNode.getAttribute('data-i18n'))
const isStandalone = !!adminSettingsPath

export {
  version,
  basePath,
  adminSettingsPath,
  canCanRules,
  i18nDict,
  isStandalone
}
