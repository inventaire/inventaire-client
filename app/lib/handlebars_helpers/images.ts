// This is tailored for handlebars, for other uses, use app.API.img directly.
// Keep in sync with server/lib/emails/handlebars_helpers
import { isNumber, isArray } from 'underscore'
import { isDataUrl } from '#lib/boolean_tests'

export const imgSrc = (path, width, height) => {
  if (isDataUrl(path)) return path

  width = getImgDimension(width, 1600)
  width = bestImageWidth(width)
  height = getImgDimension(height, width)
  path = onePictureOnly(path)

  if (window.devicePixelRatio !== 1) {
    width = getScaledSize(width)
    height = getScaledSize(height)
  }

  if (path == null) return ''

  return app.API.img(path, width, height)
}

export default { imgSrc }

const onePictureOnly = arg => isArray(arg) ? arg[0] : arg

const getImgDimension = function (dimension, defaultValue) {
  if (isNumber(dimension)) {
    return dimension
  } else {
    return defaultValue
  }
}

const bestImageWidth = function (width) {
  // under 500, it's useful to keep the freedom to get exactly 64 or 128px etc
  // while still grouping on the initially requested width
  if (width < 500) return width

  // if in a browser, use the screen width as a max value
  if (screen?.width) width = Math.min(width, screen.width)
  // group image width above 500 by levels of 100px to limit generated versions
  return Math.ceil(width / 100) * 100
}

// Regroup image dimensions to avoid generating and caching too many different sizes
const getScaledSize = size => {
  const scaledSize = window.devicePixelRatio * size
  for (const value of thresolds) {
    if (scaledSize <= value) return value
  }
  return thresolds.slice(-1)[0]
}

const thresolds = [
  48,
  64,
  96,
  100,
  128,
  150,
  200,
  300,
  400,
  500,
  1000,
  1600,
]
