import { reactive } from 'vue'

function assignReferenceToModels (schema) {
  schema.forEach((model) => {
    model.columns.forEach((column) => {
      const reference = model.associations.find((assoc) => {
        return assoc.foreign_key === column.name && assoc.association_type === 'belongs_to'
      })

      if (reference) {
        column.reference = reference
      }
    })
  })

  return schema
}

const appNode = document.getElementById('app')

const schema = reactive(assignReferenceToModels(JSON.parse(appNode.getAttribute('data-schema'))))
const modelSlugMap = Object.fromEntries(schema.map((res) => [res.slug, res]))
const modelNameMap = Object.fromEntries(schema.map((res) => [res.name, res]))

export { schema, modelSlugMap, modelNameMap }
