function truncate (string, length) {
  if (string && string.length > length) {
    return string.slice(0, length) + '...'
  } else {
    return string
  }
}

function underscore (string) {
  return string.replace(/([a-z\d])([A-Z]+)/g, '$1_$2').replace(/[-\s]+/g, '_').toLowerCase()
}

function titleize (string) {
  if (string) {
    return string.replace(/_+/g, ' ').replace(/(?:^|\s|-)\S/g, x => x.toUpperCase())
  } else {
    return ''
  }
}

function interpolate (string, params) {
  return string.replace(/{{?(\w+)}}?/g, (expr, key) => {
    return params[key]
  })
}

function naiveMustache (string, data) {
  return string.replace(/{{(\w+)}}/g, (expresion, key) => data[key] || expresion)
}

export { truncate, underscore, titleize, interpolate, naiveMustache }
