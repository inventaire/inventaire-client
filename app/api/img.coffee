module.exports = (path, width, height)->
  if /^http/.test path
    key = _.hashCode path
    href = encodeURIComponent path
    "/img/#{width}x#{height}/#{key}?href=#{href}"
  else
    "/img/#{width}x#{height}/#{path}"
