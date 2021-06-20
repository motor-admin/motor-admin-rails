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
