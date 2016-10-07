# Allowing a root parameter to let the server pass its host value
# in email templates
module.exports = (_, root='')->
  return img = (path, width=1600, height=1600)->
    unless _.isNonEmptyString path then return

    # Converting IPFS paths to an HTTP(S) gateway url
    # Letting the hash length rough: it seem to always be 46
    # but no spec could be found to confirm it won't change
    if /^\/ipfs\/\w{30,60}$/.test path
      path = "https://ipfs.io#{path}"

    if /^http/.test path
      key = _.hashCode path
      href = _.fixedEncodeURIComponent path
      "#{root}/img/#{width}x#{height}/#{key}?href=#{href}"
    else
      path = path.replace '/img/', ''
      "#{root}/img/#{width}x#{height}/#{path}"
