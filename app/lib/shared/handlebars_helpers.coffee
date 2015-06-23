module.exports = (_)->
  # filter.to documentation: http://cdn.filter.to/faq/
  src: (path, width, height, extend)->
    width = _.bestImageWidth width
    if _.isArray(path) then path = path[0]

    return ''  unless path?

    # testing with isNumber due to {data:,hash: }
    # being added as last argument
    return path  unless _.isNumber(width)

    if /wikimedia.org/.test(path)
      return optimizedCommonsImg path, width

    if /gravatar.com/.test(path) then path = cleanGravatarPath path

    return _.cdn path, width, height, extend


# not using gravatar directly even if it offers https
# as its performence are too variable => using cdn
cleanGravatarPath = (path)->
  path
  # removing any size parameter
  .replace /&s=\d+/g, ''
  # replacing https by http to conform to filter.to limits
  .replace 'https', 'http'

# cdn.filter.to can't handle wikimedia images now that they are behind https
# so here is a hack to limit to download height resolution picture when thumbnails
# are needed
optimizedCommonsImg = (path, width)->
  if width < 300
    file = path.split('/').slice(-1)
    return "http://commons.wikimedia.org/w/thumb.php?width=#{width}&f=#{file}"
  else return path
