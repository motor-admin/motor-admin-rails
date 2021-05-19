import { modelNameMap } from '../scripts/schema'

function selectReadableColumns (columns) {
  return columns.map((column) => {
    return ['read_only', 'read_write'].includes(column.access_type)
      ? column.name
      : null
  }).filter(Boolean).join(',')
}

function includeParams (model) {
  return model.columns.map((column) => {
    return ['read_only', 'read_write'].includes(column.access_type) && column.reference?.name
      ? column.reference.name
      : null
  }).filter(Boolean).join(',')
}

function fieldsParams (model) {
  const fields = {
    [model.name]: selectReadableColumns(model.columns)
  }

  model.columns.forEach((column) => {
    if (column.reference?.name && !column.reference.polymorphic && ['read_only', 'read_write'].includes(column.access_type)) {
      const referenceModel = modelNameMap[column.reference.model_name]

      fields[column.reference.name] ||= selectReadableColumns(referenceModel.columns)
    }
  })

  return fields
}

export { includeParams, fieldsParams }
