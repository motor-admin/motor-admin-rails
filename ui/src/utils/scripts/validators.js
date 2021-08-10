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
    } else {
      return new Error(i18nDict.field_is_not_a_number.replace('%{field}', rule.fullField))
    }
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
  }
}
