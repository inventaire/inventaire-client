# Allowing a root parameter to let the server pass its host value
# in email templates
module.exports = (_, root = '')->
  return img = (path, width = 1600, height = 1600)->
    unless _.isNonEmptyString path then return

    # Converting image hashes to a full URL
    if _.isImageHash path
      "#{root}/img/#{width}x#{height}/#{path}"

    else if /^http/.test path
      key = _.hashCode path
      href = _.fixedEncodeURIComponent path
      "#{root}/img/#{width}x#{height}/#{key}?href=#{href}"

    else if _.isEntityUri path
      _.buildPath "#{root}/api/entities",
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
      "#{root}/img/#{width}x#{height}/#{path}"
