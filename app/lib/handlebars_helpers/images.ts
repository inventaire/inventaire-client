import { isNumber } from 'underscore'
import { API } from '#app/api/api'
// This is tailored for handlebars, for other uses, use API.img directly.
// Keep in sync with server/lib/emails/handlebars_helpers
import { isImageDataUrl } from '#app/lib/boolean_tests'
import type { Url } from '#server/types/common'
import type { ImageDataUrl, ImagePath } from '#server/types/image'
import { getViewportWidth } from '../screen'

export function imgSrc (path: ImagePath | Url, width: number, height?: number): Url
export function imgSrc (path: ImageDataUrl): ImageDataUrl
export function imgSrc (): ''
export function imgSrc (path?: ImagePath | ImageDataUrl | Url, width?: number, height?: number) {
  if (isImageDataUrl(path)) return path

  width = getImgDimension(width, 1600)
  width = bestImageWidth(width)
  height = getImgDimension(height, width)

  if (window.devicePixelRatio !== 1) {
    width = getScaledSize(width)
    height = getScaledSize(height)
  }

  if (path == null) return ''

  return API.img(path, width, height)
}

export default { imgSrc }

function getImgDimension (dimension: number, defaultValue: number) {
  if (isNumber(dimension)) {
    return dimension
  } else {
    return defaultValue
  }
}

function bestImageWidth (width: number) {
  // under 500, it's useful to keep the freedom to get exactly 64 or 128px etc
  // while still grouping on the initially requested width
  if (width < 500) return width

  // Use the visualViewport width as a max value
  const visualViewportWidth = getViewportWidth()
  if (visualViewportWidth) width = Math.min(width, visualViewportWidth)
  // group image width above 500 by levels of 100px to limit generated versions
  return Math.ceil(width / 100) * 100
}

// Regroup image dimensions to avoid generating and caching too many different sizes
function getScaledSize (size: number) {
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
