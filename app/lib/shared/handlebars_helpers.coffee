module.exports = (_)->
  # filter.to documentation: http://cdn.filter.to/faq/
  src: (path, width, height, extend)->
    if _.isArray(path) then path = path[0]

    return ''  unless path?

    # testing with isNumber due to {data:,hash: }
    # being added as last argument
    return path  unless _.isNumber(width)

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
