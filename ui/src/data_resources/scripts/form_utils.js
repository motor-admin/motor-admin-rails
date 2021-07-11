import Validators from 'utils/scripts/validators'
import { i18nDict } from 'utils/scripts/configs'

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
      return {
        required: true,
        message: i18nDict.field_is_required.replace('%{field}', column.display_name)
      }
    } else if (validator.format) {
      return {
        pattern: new RegExp(validator.format.source, validator.format.options),
        message: i18nDict.field_value_does_not_match_pattern.replace('%{field}', column.display_name).replace('%{pattern}', validator.format.source)
      }
    } else if (validator.includes) {
      return {
        required: true,
        message: i18nDict.field_is_required.replace('%{field}', column.display_name)
      }
    } else if (validator.length) {
      return {
        len: validator.length,
        message: i18nDict.field_must_be_exactly_in_length.replace('%{field}', column.display_name)
      }
    } else if (validator.numeric) {
      return [
        {
          type: 'number',
          message: i18nDict.field_is_not_a_number.replace('%{field}', column.display_name)
        },
        {
          required: !validator.numeric.allow_nil,
          message: i18nDict.field_is_required.replace('%{field}', column.display_name)
        },
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

function buildDefaultValues (model) {
  return model.columns.reduce((acc, column) => {
    if (column.default_value !== null) {
      acc[column.name] = column.default_value
    }

    return acc
  }, {})
}

export { isJsonColumn, buildColumnValidator, buildDefaultValues }
