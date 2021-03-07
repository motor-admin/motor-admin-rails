const appNode = document.getElementById('app')

const basePath = appNode.getAttribute('data-base-path')
const schema = JSON.parse(appNode.getAttribute('data-schema'))

export { basePath, schema }
