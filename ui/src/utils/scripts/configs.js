const appNode = document.getElementById('app')

const basePath = appNode.getAttribute('data-base-path')
const canCanRules = JSON.parse(appNode.getAttribute('data-current-rules'))
const i18nDict = JSON.parse(appNode.getAttribute('data-i18n'))

export { basePath, canCanRules, i18nDict }
