import { isNumber, isArray } from 'underscore'
import app from '#app/app'
// This is tailored for handlebars, for other uses, use app.API.img directly.
// Keep in sync with server/lib/emails/handlebars_helpers
import { isImageDataUrl } from '#lib/boolean_tests'
import type { Url } from '#server/types/common'
import type { ImageDataUrl, ImagePath } from '#server/types/image'

export function imgSrc (path: ImagePath | Url, width: number, height?: number): Url
export function imgSrc (path: ImageDataUrl): ImageDataUrl
export function imgSrc (): ''
export function imgSrc (path?: ImagePath | ImageDataUrl | Url, width?: number, height?: number) {
  if (isImageDataUrl(path)) return path

  width = getImgDimension(width, 1600)
  width = bestImageWidth(width)
  height = getImgDimension(height, width)
  path = onePictureOnly(path)

  if (window.devicePixelRatio !== 1) {
    width = getScaledSize(width)
    height = getScaledSize(height)
  }

  if (path == null) return ''

  return app.API.img(path, width, height) as Url
}

export default { imgSrc }

const onePictureOnly = arg => isArray(arg) ? arg[0] : arg

function getImgDimension (dimension, defaultValue) {
  if (isNumber(dimension)) {
    return dimension
  } else {
    return defaultValue
  }
}

function bestImageWidth (width) {
  // under 500, it's useful to keep the freedom to get exactly 64 or 128px etc
  // while still grouping on the initially requested width
  if (width < 500) return width

  // if in a browser, use the screen width as a max value
  if (screen?.width) width = Math.min(width, screen.width)
  // group image width above 500 by levels of 100px to limit generated versions
  return Math.ceil(width / 100) * 100
}

// Regroup image dimensions to avoid generating and caching too many different sizes
function getScaledSize (size) {
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
