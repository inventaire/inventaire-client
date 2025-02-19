import { config } from '#app/config'
import { isNonEmptyString, isEntityUri, isAssetImg, isLocalImg, isImageHash } from '#app/lib/boolean_tests'
import { buildPath } from '#app/lib/location'
import { fixedEncodeURIComponent, hashCode } from '#app/lib/utils'
import { thumbnail } from '#app/lib/wikimedia/commons'
import type { Url } from '#server/types/common'
import type { EntityUri } from '#server/types/entity'
import type { ImagePath } from '#server/types/image'

const { remoteEntitiesOrigin } = config
const entitiesImagesOrigin = remoteEntitiesOrigin || ''

// Keep in sync with server/lib/emails/app_api
export default function (path: ImagePath | Url | EntityUri, width = 1600, height = 1600) {
  if (!isNonEmptyString(path)) return

  // Converting image hashes to a full URL
  if (isLocalImg(path) || isAssetImg(path)) {
    const [ container, filename ] = path.split('/').slice(2)
    const origin = container === 'entities' ? entitiesImagesOrigin : ''
    return `${origin}/img/${container}/${width}x${height}/${filename}` as Url
  }

  // The server may return images path on upload.wikimedia.org
  if (path.startsWith('https://upload.wikimedia.org')) {
    const file = path.split('/').slice(-1)[0]
    return thumbnail(file, width)
  }

  if (path.startsWith('http')) {
    const key = hashCode(path)
    const href = fixedEncodeURIComponent(path)
    return `${origin}/img/remote/${width}x${height}/${key}?href=${href}` as Url
  }

  // Current use-case: app/modules/search/lib/search_results.ts subjects
  if (isEntityUri(path)) {
    const url = `${entitiesImagesOrigin}/api/entities` as Url
    return buildPath(url, {
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
