import { reactive } from 'vue'

const appNode = document.getElementById('app')

const schema = reactive(JSON.parse(appNode.getAttribute('data-schema')))
const modelSlugMap = Object.fromEntries(schema.map((res) => [res.slug, res]))
const modelNameMap = Object.fromEntries(schema.map((res) => [res.name, res]))
const modelClassNameMap = Object.fromEntries(schema.map((res) => [res.class_name, res]))

// Rails ActiveRecord::Base.composite_primary_key_separator default.
const COMPOSITE_PK_SEPARATOR = '_'

function isCompositePrimaryKey (model) {
  return Array.isArray(model?.primary_key)
}

function primaryKeyColumns (model) {
  if (!model?.primary_key) {
    return []
  }
  return isCompositePrimaryKey(model) ? model.primary_key : [model.primary_key]
}

function isPrimaryKeyColumn (model, columnName) {
  return primaryKeyColumns(model).includes(columnName)
}

function primaryKeyParam (model, resource) {
  if (!resource) {
    return null
  }
  if (isCompositePrimaryKey(model)) {
    return model.primary_key.map((pk) => resource[pk]).join(COMPOSITE_PK_SEPARATOR)
  }
  return resource[model.primary_key]
}

function primaryKeySortString (model, order) {
  const prefix = order === 'desc' ? '-' : ''
  return primaryKeyColumns(model).map((c) => `${prefix}${c}`).join(',')
}

export {
  schema,
  modelSlugMap,
  modelNameMap,
  modelClassNameMap,
  COMPOSITE_PK_SEPARATOR,
  isCompositePrimaryKey,
  primaryKeyColumns,
  isPrimaryKeyColumn,
  primaryKeyParam,
  primaryKeySortString
}
