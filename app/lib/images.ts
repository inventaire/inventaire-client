import _dataURLtoBlob from 'blueimp-canvas-to-blob'
import { sample } from 'underscore'
import { API } from '#app/api/api'
import { isImageDataUrl } from '#app/lib/boolean_tests'
import { newError } from '#app/lib/error'
import preq from '#app/lib/preq'
import { forceArray } from '#app/lib/utils'
import type { ColorHexCode, Url } from '#server/types/common'
import type { CouchUuid } from '#server/types/couchdb'
import type { ImageContainer, ImageDataUrl } from '#server/types/image'

export async function getUrlDataUrl (url: Url) {
  const { 'data-url': dataUrl } = await preq.get(API.images.dataUrl(url))
  return dataUrl
}

export async function getUserGravatarUrl () {
  const { url } = await preq.get(API.images.gravatar)
  return url
}

interface ImageDimensions {
  width?: number
  height?: number
}
interface ImageData {
  original: ImageDimensions
  resized: ImageDimensions
  dataUrl?: string
}

export function resizeDataUrl (dataURL: ImageDataUrl, maxSize: number, outputQuality: number = 1): Promise<ImageData> {
  return new Promise((resolve, reject) => {
    const data: ImageData = { original: {}, resized: {} }
    const image = new Image()
    image.onload = () => {
      const canvas = document.createElement('canvas')
      let { width, height } = image
      data.original = { width, height }
      ;[ width, height ] = getResizedDimensions(width, height, maxSize)
      data.resized = { width, height }

      canvas.width = width
      canvas.height = height
      canvas.getContext('2d').drawImage(image, 0, 0, width, height)
      data.dataUrl = canvas.toDataURL('image/jpeg', outputQuality)
      return resolve(data)
    }

    // This exact message is expected by the Img model
    image.onerror = () => reject(new Error('invalid image'))

    image.src = dataURL
  })
}

export function dataUrlToBlob (data) {
  if (isImageDataUrl(data)) return _dataURLtoBlob(data)
  else throw new Error('expected a dataURL')
}

export async function upload (container: ImageContainer, blobsData, hash = false) {
  blobsData = forceArray(blobsData)
  const formData = new FormData()

  let i = 0
  for (const blobData of blobsData) {
    let { blob, id } = blobData
    if (blob == null) throw newError('missing blob', blobData)
    if (!id) id = `file-${++i}`
    formData.append(id, blob)
  }

  return new Promise((resolve, reject) => {
    const request = new XMLHttpRequest()
    request.onreadystatechange = function () {
      if (request.readyState === 4) {
        const { status, statusText } = request
        if (/^2/.test(request.status.toString())) {
          return resolve(request.response)
        } else {
          return reject(newError(statusText, status))
        }
      }
    }
    request.onerror = reject
    request.ontimeout = reject

    request.open('POST', API.images.upload(container, hash))
    request.responseType = 'json'
    return request.send(formData)
  })
}

export async function getImageHashFromDataUrl (container: ImageContainer, dataUrl: ImageDataUrl) {
  if (!isImageDataUrl(dataUrl)) throw newError('invalid image', dataUrl)
  return upload(container, { blob: dataUrlToBlob(dataUrl) }, true)
  .then(res => Object.values(res)[0].split('/').slice(-1)[0])
}

export function getNonResizedUrl (url: Url) {
  return url.replace(/\/img\/users\/\d+x\d+\//, '/img/')
}

export function getColorSquareDataUri (colorHexCode: string) {
  colorHexCode = normalizeColorHexCode(colorHexCode)
  // Using the base64 version and not the utf8, as it gets problematic
  // when used as background-image '<div style="background-image: url({{imgSrc picture 100}})"'
  const base64Hash = btoa(`<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 1 1'><path d='M0,0h1v1H0' fill='${colorHexCode}'/></svg>`)
  return `data:image/svg+xml;base64,${base64Hash}` as ImageDataUrl
}

const normalizeColorHexCode = code => (code[0] === '#' ? code : `#${code}`) as ColorHexCode

export function getColorSquareDataUriFromCouchUuId (couchUuid: CouchUuid) {
  const colorHexCode = getColorHexCodeFromCouchUuId(couchUuid)
  return getColorSquareDataUri(colorHexCode)
}

function getResizedDimensions (width, height, maxSize) {
  if (width > height) {
    if (width > maxSize) {
      height *= maxSize / width
      width = maxSize
    }
  } else {
    if (height > maxSize) {
      width *= maxSize / height
      height = maxSize
    }
  }
  return [ width, height ]
}

// Inspired by https://www.materialpalette.com/colors
const someSuggestedColors = [
  '009688',
  '00bcd4',
  '03a9f4',
  '2196f3',
  '3f51b5',
  '4caf50',
  '607d8b',
  '673ab7',
  '795548',
  '8bc34a',
  '9c27b0',
  '9e9e9e',
  'cddc39',
]

export function getColorHexCodeFromCouchUuId (couchUuid) {
  if (couchUuid == null) return someSuggestedColors[0]
  const someStableModelNumber = parseInt(couchUuid.slice(-2), 16)
  // Pick one of the colors based on the group slug length
  const index = someStableModelNumber % someSuggestedColors.length
  return someSuggestedColors[index]
}

export const getSomeColorHexCodeSuggestion = () => `#${sample(someSuggestedColors)}`

let Cropper, waitingForCropper
export async function getCropper () {
  if (waitingForCropper) return Cropper
  waitingForCropper = Promise.all([
    import('cropperjs'),
    import('cropperjs/dist/cropper.css'),
  ])
  ;([ { default: Cropper } ] = await waitingForCropper)
  return Cropper
}
