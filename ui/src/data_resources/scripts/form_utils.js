import Validators from 'utils/scripts/validators'
import { i18nDict } from 'utils/scripts/configs'

function isJsonColumn (column, resource) {
  return (column.column_type === 'json' ||
    (resource[column.name] instanceof Object &&
      resource[column.name].constructor === Object)) &&
    !['file', 'image', 'reference'].includes(column.column_type)
}

function buildColumnValidator (column, resource) {
  if (column.is_array) {
    return []
  }

  const validators = (column.validators || []).map((validator) => {
    if (validator.required) {
      return {
        required: true,
        message: i18nDict.field_is_required.replace('%{field}', column.display_name)
      }
    } else if (validator.format) {
      const regexp = validator.format.source
        ? new RegExp(validator.format.source, validator.format.options)
        : new RegExp(validator.format)

      return {
        pattern: regexp,
        message: validator.message || i18nDict.field_value_does_not_match_pattern.replace('%{field}', column.display_name).replace('%{pattern}', validator.format.source),
        trigger: 'blur'
      }
    } else if (validator.includes) {
      return {
        required: true,
        message: i18nDict.field_is_required.replace('%{field}', column.display_name)
      }
    } else if (validator.length) {
      return {
        validator: Validators.length,
        fullField: column.display_name,
        options: validator.length
      }
    } else if (validator.numeric) {
      return [
        {
          validator: Validators.number,
          fullField: column.display_name
        },
        {
          required: !validator.numeric.allow_nil && !validator.numeric.allow_blank,
          message: i18nDict.field_is_required.replace('%{field}', column.display_name)
        },
        {
          required: !validator.numeric.allow_nil && !validator.numeric.allow_blank,
          validator: Validators.numeric,
          fullField: column.display_name,
          options: validator.numeric
        }
      ]
    } else {
      return null
    }
  }).filter(Boolean).flat()

  if (column.name === 'email') {
    validators.push({ type: 'email', trigger: 'blur' })
  }

  if (isJsonColumn(column, resource)) {
    validators.push({
      validator: Validators.json,
      fullField: column.display_name,
      trigger: 'blur'
    })
  }

  if (!column.reference && ['integer', 'float'].includes(column.column_type)) {
    validators.push({
      validator: Validators.number,
      fullField: column.display_name
    })
  }

  return validators
}

function buildDefaultValues (model) {
  return model.columns.reduce((acc, column) => {
    if (column.column_type === 'association') {
      acc[column.name] = column.default_value || []
    } else if (column.default_value !== null) {
      acc[column.name] = column.default_value
    }

    return acc
  }, {})
}

export { isJsonColumn, buildColumnValidator, buildDefaultValues }
