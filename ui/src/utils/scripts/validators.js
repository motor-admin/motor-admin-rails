import { i18nDict } from 'utils/scripts/configs'

const VALIDATORS = {
  greater_than: (option, value) => {
    return value > option
  },
  greater_than_or_equal_to: (option, value) => {
    return value >= option
  },
  equal_to: (option, value) => {
    return parseFloat(value) === parseFloat(option)
  },
  less_than: (option, value) => {
    return value < option
  },
  less_than_or_equal_to: (option, value) => {
    return value <= option
  },
  other_than: (option, value) => {
    return parseFloat(value) !== parseFloat(option)
  }
}

export default {
  numeric (rule, value, callbacks) {
    if (![null, undefined, ''].includes(value)) {
      const [error, constraint] = Object.entries(rule.options).find(([key, constraint]) => {
        if (VALIDATORS[key]) {
          return !VALIDATORS[key](constraint, value)
        } else {
          return false
        }
      }) || []

      if (error) {
        return new Error(i18nDict.should_be_error_constraint.replace('%{field}', rule.fullField).replace('%{error}', i18nDict[error].toLowerCase()).replace('%{constraint}', constraint))
      } else {
        return true
      }
    } else {
      return true
    }
  },
  number (rule, value, callbacks, source, options) {
    const valueType = typeof value

    if (valueType === 'number') {
      return true
    } else if (valueType === 'string' && value.match(/^\d+(?:\.\d+)?$/)) {
      return true
    } else if (value) {
      return new Error(i18nDict.field_is_not_a_number.replace('%{field}', rule.fullField))
    } else {
      return true
    }
  },
  length (rule, value, callbacks, source, options) {
    const stringValue = value.toString()
    const normalizedOptions = { ...rule.options }

    if (normalizedOptions.in) {
      normalizedOptions.minimum = normalizedOptions.in[0]
      normalizedOptions.maximum = normalizedOptions.in[1]

      delete normalizedOptions.in
    }

    if (!value && (rule.options.allow_blank || rule.options.allow_nil)) {
      return true
    }

    return Object.entries(normalizedOptions).reduce((acc, [key, value]) => {
      if (key === 'is' && stringValue.length !== value) {
        return new Error(i18nDict.field_must_be_exactly_in_length.replace('%{field}', rule.fullField).replace('%{length}', value))
      } else if (key === 'minimum' && stringValue.length < value) {
        return new Error(i18nDict.field_must_be_more_in_length.replace('%{field}', rule.fullField).replace('%{length}', value))
      } else if (key === 'maximum' && stringValue.length > value) {
        return new Error(i18nDict.field_must_be_less_in_length.replace('%{field}', rule.fullField).replace('%{length}', value))
      }

      return acc
    }, true)
  },
  json (rule, value, callbacks) {
    try {
      if (value) {
        JSON.parse(value)
      }

      return true
    } catch {
      return new Error(i18nDict.should_be_a_valid_json.replace('%{field}', rule.fullField))
    }
  },
  regexp (rule, value, callbacks) {
    try {
      if (value) {
        new RegExp(value) // eslint-disable-line no-new
      }

      return true
    } catch {
      return new Error(i18nDict.should_be_a_valid_regexp.replace('%{field}', rule.fullField))
    }
  }
}
