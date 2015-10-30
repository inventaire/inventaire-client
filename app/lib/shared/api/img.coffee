# allowing a root parameter to let the server pass its host value
# in email templates
module.exports = (_, root='')->
  return img = (path, width=1600, height=1600)->
    if /^http/.test path
      key = _.hashCode path
      href = encodeURIComponent path
      "#{root}/img/#{width}x#{height}/#{key}?href=#{href}"
    else
      path = path.replace '/img/', ''
      "#{root}/img/#{width}x#{height}/#{path}"
