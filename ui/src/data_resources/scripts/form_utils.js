import Validators from 'utils/scripts/validators'

function isJsonColumn (column, resource) {
  return (column.column_type === 'json' ||
    (resource[column.name] instanceof Object &&
      resource[column.name].constructor === Object)) &&
    !['file', 'image'].includes(column.column_type)
}

function buildColumnValidator (column, resource) {
  if (column.is_array) {
    return []
  }

  const validators = column.validators.map((validator) => {
    if (validator.required) {
      return { required: true }
    } else if (validator.format) {
      return { pattern: new RegExp(validator.format.source, validator.format.options) }
    } else if (validator.includes) {
      return { required: true }
    } else if (validator.length) {
      return { len: validator.length }
    } else if (validator.numeric) {
      return [
        { type: 'number' },
        { required: !validator.numeric.allow_nil },
        {
          required: !validator.numeric.allow_nil,
          validator: Validators.numeric,
          options: validator.numeric
        }
      ]
    } else {
      return null
    }
  }).filter(Boolean).flat()

  if (column.name === 'email') {
    validators.push({ type: 'email' })
  }

  if (isJsonColumn(column, resource)) {
    validators.push({ validator: Validators.json })
  }

  if (!column.reference && ['integer', 'float'].includes(column.column_type)) {
    validators.push({ type: 'number' })
  }

  return validators
}

export { isJsonColumn, buildColumnValidator }
