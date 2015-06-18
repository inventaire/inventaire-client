module.exports = (_)->
  # filter.to documentation: http://cdn.filter.to/faq/
  src: (path, width, height, extend)->
    if _.isArray(path) then path = path[0]

    return ''  unless path?

    # testing with isNumber due to {data:,hash: }
    # being added as last argument
    return path  unless _.isNumber(width)

    if /gravatar.com/.test(path) then cleanGravatarPath path, width
    else _.cdn path, width, height, extend


cleanGravatarPath = (path, width)->
  # removing any size parameter
  path = path.replace /&s=\d+/g, ''

  return path + "&s=#{width}"
