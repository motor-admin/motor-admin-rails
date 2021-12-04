import { modelNameMap } from '../scripts/schema'

function selectReadableColumns (model, accessTypes = ['read_only', 'read_write']) {
  return model.columns.map((column) => {
    return accessTypes.includes(column.access_type) || model.primary_key === column.name
      ? column.name
      : null
  }).filter(Boolean).join(',')
}

function includeParams (model, accessTypes = ['read_only', 'read_write']) {
  return model.columns.map((column) => {
    return accessTypes.includes(column.access_type) && column.reference?.name
      ? column.reference.name
      : null
  }).filter(Boolean).join(',')
}

function fieldsParams (model, accessTypes = ['read_only', 'read_write']) {
  const fields = {
    [model.name]: selectReadableColumns(model, accessTypes)
  }

  model.columns.forEach((column) => {
    if (column.reference?.name && !column.reference.polymorphic && accessTypes.includes(column.access_type)) {
      const referenceModel = modelNameMap[column.reference.model_name]

      if (referenceModel) {
        fields[column.reference.name] ||= selectReadableColumns(referenceModel, accessTypes)
      }
    }
  })

  return fields
}

export { includeParams, fieldsParams }
