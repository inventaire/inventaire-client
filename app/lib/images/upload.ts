import _dataURLtoBlob from 'blueimp-canvas-to-blob'
import { API } from '#app/api/api'
import { newError } from '#app/lib/error'
import type { ImageContainer, ImageDataUrl } from '#server/types/image'
import { isImageDataUrl } from '../boolean_tests'
import { forceArray } from '../utils'

export async function getImageHashFromDataUrl (container: ImageContainer, dataUrl: ImageDataUrl) {
  if (!isImageDataUrl(dataUrl)) throw newError('invalid image', dataUrl)
  const res = await upload(container, { blob: dataUrlToBlob(dataUrl) }, true)
  return Object.values(res)[0].split('/').slice(-1)[0]
}

function dataUrlToBlob (data) {
  if (isImageDataUrl(data)) return _dataURLtoBlob(data)
  else throw new Error('expected a dataURL')
}

async function upload (container: ImageContainer, blobsData, hash = false) {
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
