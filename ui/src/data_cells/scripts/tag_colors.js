import ColorHash from 'color-hash'

const colorsStore = {}

function colorsForTag (text) {
  const colors = colorsStore[text]

  if (colors) {
    return colors
  } else {
    return [new ColorHash({ lightness: 0.9 }).hex(text), new ColorHash({ lightness: 0.4 }).hex(text)]
  }
}

export { colorsForTag }
