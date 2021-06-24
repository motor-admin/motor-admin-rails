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
        return new Error(i18nDict.should_be_error_constraint.replace('%{error}', i18nDict[error].toLowerCase()).replace('%{constraint}', constraint))
      } else {
        return true
      }
    } else {
      return true
    }
  },
  json (rule, value, callbacks) {
    try {
      if (value) {
        JSON.parse(value)
      }

      return true
    } catch {
      return new Error(i18nDict.should_be_a_valid_json)
    }
  }
}
