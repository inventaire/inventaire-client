{ buildPath } = require 'lib/location'
commons_ = require 'lib/wikimedia/commons'

# Keep in sync with server/lib/emails/app_api
module.exports = (path, width = 1600, height = 1600)->
  unless _.isNonEmptyString path then return

  if path.startsWith '/ipfs/'
    console.warn 'outdated img path', path
    return

  # Converting image hashes to a full URL
  if _.isLocalImg(path) or _.isAssetImg(path)
    [ container, filename ] = path.split('/').slice(2)
    return "/img/#{container}/#{width}x#{height}/#{filename}"

  # The server may return images path on upload.wikimedia.org
  if path.startsWith 'https://upload.wikimedia.org'
    file = path.split('/').slice(-1)[0]
    return commons_.thumbnail file, width

  if path.startsWith 'http'
    key = _.hashCode path
    href = _.fixedEncodeURIComponent path
    return "/img/remote/#{width}x#{height}/#{key}?href=#{href}"

  if _.isEntityUri path
    return buildPath '/api/entities',
      action: 'images'
      uris: path
      redirect: true
      width: width
      height: height

  if _.isImageHash path
    console.warn 'image hash without container', path
    console.trace()
    return

  # Assumes this is a Wikimedia Commons filename
  if path[0] isnt '/' then return commons_.thumbnail path, width

  path = path.replace '/img/', ''
  return "/img/#{width}x#{height}/#{path}"
