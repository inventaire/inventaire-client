import { buildPath } from 'lib/location'
import commons_ from 'lib/wikimedia/commons'

// Keep in sync with server/lib/emails/app_api
export default function (path, width = 1600, height = 1600) {
  if (!_.isNonEmptyString(path)) { return }

  if (path.startsWith('/ipfs/')) {
    console.warn('outdated img path', path)
    return
  }

  // Converting image hashes to a full URL
  if (_.isLocalImg(path) || _.isAssetImg(path)) {
    const [ container, filename ] = Array.from(path.split('/').slice(2))
    return `/img/${container}/${width}x${height}/${filename}`
  }

  // The server may return images path on upload.wikimedia.org
  if (path.startsWith('https://upload.wikimedia.org')) {
    const file = path.split('/').slice(-1)[0]
    return commons_.thumbnail(file, width)
  }

  if (path.startsWith('http')) {
    const key = _.hashCode(path)
    const href = _.fixedEncodeURIComponent(path)
    return `/img/remote/${width}x${height}/${key}?href=${href}`
  }

  if (_.isEntityUri(path)) {
    return buildPath('/api/entities', {
      action: 'images',
      uris: path,
      redirect: true,
      width,
      height
    })
  }

  if (_.isImageHash(path)) {
    console.warn('image hash without container', path)
    console.trace()
    return
  }

  // Assumes this is a Wikimedia Commons filename
  if (path[0] !== '/') { return commons_.thumbnail(path, width) }

  path = path.replace('/img/', '')
  return `/img/${width}x${height}/${path}`
};
