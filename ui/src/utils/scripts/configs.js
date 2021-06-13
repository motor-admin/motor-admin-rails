const appNode = document.getElementById('app')

const basePath = appNode.getAttribute('data-base-path')
const canCanRules = JSON.parse(appNode.getAttribute('data-current-rules'))

export { basePath, canCanRules }
