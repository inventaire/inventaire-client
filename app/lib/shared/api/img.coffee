# allowing a root parameter to let the server pass its host value
# in email templates
module.exports = (_, root='')->
  return img = (path, width, height)->
    if /^http/.test path
      key = _.hashCode path
      href = encodeURIComponent path
      "#{root}/img/#{width}x#{height}/#{key}?href=#{href}"
    else
      "#{root}/img/#{width}x#{height}/#{path}"
