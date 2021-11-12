import ColorHash from 'color-hash'

const colorsStore = {}

function colorsForTag (text) {
  let colors = colorsStore[text]

  if (!colors) {
    let params = {}

    if (text && text.toString().match(/^not[_\s]/i)) {
      params = { hue: { min: 0, max: 60 } }
    }

    colors = [
      new ColorHash({ ...params, lightness: 0.9 }).hex(text.toString()),
      new ColorHash({ ...params, lightness: 0.4 }).hex(text.toString())
    ]

    colorsStore[text] = colors
  }

  return colors
}

export { colorsForTag }
