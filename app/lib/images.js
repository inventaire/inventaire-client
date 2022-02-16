import { forceArray } from '#lib/utils'
import preq from '#lib/preq'
import error_ from '#lib/error'
import _dataURLtoBlob from 'blueimp-canvas-to-blob'
import { isDataUrl } from '#lib/boolean_tests'

export async function getUrlDataUrl (url) {
  const { 'data-url': dataUrl } = await preq.get(app.API.images.dataUrl(url))
  return dataUrl
}

export async function getUserGravatarUrl () {
  const { url } = await preq.get(app.API.images.gravatar)
  return url
}

export function resizeDataUrl (dataURL, maxSize, outputQuality = 1) {
  return new Promise((resolve, reject) => {
    const data = { original: {}, resized: {} }
    const image = new Image()
    image.onload = () => {
      const canvas = document.createElement('canvas')
      let { width, height } = image
      saveDimensions(data, 'original', width, height);
      [ width, height ] = getResizedDimensions(width, height, maxSize)
      saveDimensions(data, 'resized', width, height)

      canvas.width = width
      canvas.height = height
      canvas.getContext('2d').drawImage(image, 0, 0, width, height)
      data.dataUrl = canvas.toDataURL('image/jpeg', outputQuality)
      return resolve(data)
    }

    // This exact message is expected by the Img model
    image.onerror = e => reject(new Error('invalid image'))

    image.src = dataURL
  })
}

export function dataUrlToBlob (data) {
  if (isDataUrl(data)) return _dataURLtoBlob(data)
  else throw new Error('expected a dataURL')
}

export async function upload (container, blobsData, hash = false) {
  blobsData = forceArray(blobsData)
  const formData = new FormData()

  let i = 0
  for (const blobData of blobsData) {
    let { blob, id } = blobData
    if (blob == null) throw error_.new('missing blob', blobData)
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
          return reject(error_.new(statusText, status))
        }
      }
    }
    request.onerror = reject
    request.ontimeout = reject

    request.open('POST', app.API.images.upload(container, hash))
    request.responseType = 'json'
    return request.send(formData)
  })
}

export async function getImageHashFromDataUrl (container, dataUrl) {
  if (!isDataUrl(dataUrl)) throw error_.new('invalid image', dataUrl)
  return upload(container, { blob: dataUrlToBlob(dataUrl) }, true)
  .then(res => _.values(res)[0].split('/').slice(-1)[0])
}

export function getNonResizedUrl (url) {
  return url.replace(/\/img\/users\/\d+x\d+\//, '/img/')
}

export function getColorSquareDataUri (colorHexCode) {
  colorHexCode = normalizeColorHexCode(colorHexCode)
  // Using the base64 version and not the utf8, as it gets problematic
  // when used as background-image '<div style="background-image: url({{imgSrc picture 100}})"'
  const base64Hash = btoa(`<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 1 1'><path d='M0,0h1v1H0' fill='${colorHexCode}'/></svg>`)
  return `data:image/svg+xml;base64,${base64Hash}`
}

const normalizeColorHexCode = code => code[0] === '#' ? code : `#${code}`

export function getColorSquareDataUriFromModelId (modelId) {
  const colorHexCode = getColorHexCodeFromModelId(modelId)
  return getColorSquareDataUri(colorHexCode)
}

const getResizedDimensions = function (width, height, maxSize) {
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

const saveDimensions = function (data, attribute, width, height) {
  data[attribute].width = width
  data[attribute].height = height
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
  'cddc39'
]

export const getColorHexCodeFromModelId = function (modelId) {
  if (modelId == null) return someSuggestedColors[0]
  const someStableModelNumber = parseInt(modelId.slice(-2), 16)
  // Pick one of the colors based on the group slug length
  const index = someStableModelNumber % someSuggestedColors.length
  return someSuggestedColors[index]
}

export const getSomeColorHexCodeSuggestion = () => `#${_.sample(someSuggestedColors)}`
