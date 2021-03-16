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
        return !VALIDATORS[key](constraint, value)
      }) || []

      if (error) {
        return new Error(`should be ${error.replace('_', ' ')} ${constraint}`)
      } else {
        return true
      }
    } else {
      return true
    }
  }
}
