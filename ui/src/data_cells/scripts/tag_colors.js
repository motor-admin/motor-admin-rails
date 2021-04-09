import ColorHash from 'color-hash'

const colorsStore = {}

function colorsForTag (text) {
  let colors = colorsStore[text]

  if (!colors) {
    colors = [
      new ColorHash({ lightness: 0.9 }).hex(text),
      new ColorHash({ lightness: 0.4 }).hex(text)
    ]

    colorsStore[text] = colors
  }

  return colors
}

export { colorsForTag }
