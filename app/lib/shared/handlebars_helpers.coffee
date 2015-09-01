module.exports = (_)->
  # filter.to documentation: http://cdn.filter.to/faq/
  src: (path, width, height, extend)->
    if _.isDataUrl path then return path

    width = _.bestImageWidth width
    path = onePictureOnly path

    return ''  unless path?

    # testing with isNumber due to {data:,hash: }
    # being added as last argument
    return path  unless _.isNumber(width)

    if /\/img\//.test path
      return _.buildPath path, getImgParams(width, height)

    if /wikimedia.org/.test(path)
      return optimizedCommonsImg path, width

    if /gravatar.com/.test(path) then path = cleanGravatarPath path

    # return _.cdn path, width, height, extend
    return path

onePictureOnly = (arg)->
  if _.isArray(arg) then return arg[0] else arg

getImgParams = (width, height)->
  width: width  if _.isNumber width
  height: height  if _.isNumber height

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
