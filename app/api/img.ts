import { isNonEmptyString, isEntityUri, isAssetImg, isLocalImg, isImageHash } from '#lib/boolean_tests'
import { buildPath } from '#lib/location'
import { fixedEncodeURIComponent, hashCode } from '#lib/utils'
import { thumbnail } from '#lib/wikimedia/commons'

// Keep in sync with server/lib/emails/app_api
export default function (path, width = 1600, height = 1600) {
  if (!isNonEmptyString(path)) return

  // Converting image hashes to a full URL
  if (isLocalImg(path) || isAssetImg(path)) {
    const [ container, filename ] = path.split('/').slice(2)
    return `/img/${container}/${width}x${height}/${filename}`
  }

  // The server may return images path on upload.wikimedia.org
  if (path.startsWith('https://upload.wikimedia.org')) {
    const file = path.split('/').slice(-1)[0]
    return thumbnail(file, width)
  }

  if (path.startsWith('http')) {
    const key = hashCode(path)
    const href = fixedEncodeURIComponent(path)
    return `/img/remote/${width}x${height}/${key}?href=${href}`
  }

  if (isEntityUri(path)) {
    return buildPath('/api/entities', {
      action: 'images',
      uris: path,
      redirect: true,
      width,
      height,
    })
  }

  if (isImageHash(path)) {
    console.trace('image hash without container', path)
    return
  }

  // Assumes this is a Wikimedia Commons filename
  if (path[0] !== '/') return thumbnail(path, width)
}
