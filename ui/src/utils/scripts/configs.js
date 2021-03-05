const appNote = document.getElementById('app')
const basePath = appNote.dataset['base-path']
const schema = JSON.parse(appNote.dataset.schema)

export { basePath, schema }
