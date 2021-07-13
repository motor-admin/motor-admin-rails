const conitionFunctionsMap = {
  eq: (a, b) => a == b, // eslint-disable-line eqeqeq
  neq: (a, b) => a != b, // eslint-disable-line eqeqeq
  empty: (a, b) => !a && a !== 0,
  nempty: (a, b) => !!(a || a !== ''),
  contains: (a, b) => a.includes(b),
  gt: (a, b) => a > b,
  gte: (a, b) => a >= b,
  lt: (a, b) => a < b,
  lte: (a, b) => a <= b
}

export function buildDefaultValues (items) {
  return items.reduce((acc, item) => {
    if (item.default_value) {
      acc[item.name] = item.default_value || (item.is_array ? [] : '')
    } else if (item.items) {
      const defaultValues = buildDefaultValues(item.items)

      acc[item.name] = item.is_array ? [defaultValues] : defaultValues
    }

    return acc
  }, {})
}

export function checkConditions (conditions, data) {
  if (conditions?.length) {
    return conditions.reduce((acc, condition) => {
      const result = conitionFunctionsMap[condition.action](data[condition.field] ?? '', condition.value)

      return acc && result
    }, true)
  } else {
    return true
  }
}
