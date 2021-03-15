function truncate (string, length) {
  if (string && string.length > length) {
    return string.slice(0, length) + '...'
  } else {
    return string
  }
}

function underscore (string) {
  return string.replace(/([a-z\d])([A-Z]+)/g, '$1_$2')
    .replace(/[-\s]+/g, '_')
    .toLowerCase()
}

function titleize (string) {
  return string.replace(/_+/g, ' ').replace(/(?:^|\s|-)\S/g, x => x.toUpperCase())
}

export { truncate, underscore, titleize }
