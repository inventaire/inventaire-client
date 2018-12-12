{ buildPath } = require 'lib/location'

# Keep in sync with server/lib/emails/app_api
module.exports = (path, width = 1600, height = 1600)->
  unless _.isNonEmptyString path then return

  if path.startsWith '/ipfs/'
    console.warn 'outdated img path', path
    return

  # Converting image hashes to a full URL
  if _.isLocalImg(path) or _.isAssetImg(path)
    [ container, filename ] = path.split('/').slice(2)
    "/img/#{container}/#{width}x#{height}/#{filename}"

  else if /^http/.test path
    key = _.hashCode path
    href = _.fixedEncodeURIComponent path
    "/img/remote/#{width}x#{height}/#{key}?href=#{href}"

  else if _.isEntityUri path
    buildPath '/api/entities',
      action: 'images'
      uris: path
      redirect: true
      width: width
      height: height

  # Assumes this is a Wikimedia Commons filename
  else if path[0] isnt '/'
    file = _.fixedEncodeURIComponent path
    "https://commons.wikimedia.org/w/thumb.php?width=#{width}&f=#{file}"

  else
    path = path.replace '/img/', ''
    "/img/#{width}x#{height}/#{path}"
