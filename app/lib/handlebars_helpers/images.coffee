SafeString = Handlebars.SafeString

exports.icon = (name, classes) ->
  if _.isString(name)
    if icons[name]?
      src = icons[name]
      return new SafeString "<img class='icon svg' src='#{src}'>"
    else
      # overriding the second argument that could be {hash:,data:}
      unless _.isString classes then classes = ''
      return new SafeString "<i class='fa fa-#{name} #{classes}'></i>&nbsp;&nbsp;"

icons =
  wikipedia: 'https://upload.wikimedia.org/wikipedia/en/8/80/Wikipedia-logo-v2.svg'
  wikidata: 'https://upload.wikimedia.org/wikipedia/commons/f/ff/Wikidata-logo.svg'
  wikidataWhite: 'http://img.inventaire.io/Wikidata-logo-white.svg'
  wikisource: 'https://upload.wikimedia.org/wikipedia/commons/4/4c/Wikisource-logo.svg'



# filter.to documentation: http://cdn.filter.to/faq/
exports.src = (path, width, height, extend)->
  return ''  unless path?

  # testing with isNumber due to {data:,hash: }
  # being added as last argument
  return path  unless _.isNumber(width)

  if /gravatar.com/.test(path) then cleanGravatarPath path, width
  else getCdnPath path, width, height, extend

cleanGravatarPath = (path, width)->
  # removing any size parameter
  path = path.replace /&s=\d+/g, ''

  return path + "&s=#{width}"

getCdnPath = (path, width, height, extend)->
  unless _.isNumber(height) then height = width
  size = "#{width}x#{height}"
  unless extend then size += 'g'

  path = dropProtocol path

  return "http://cdn.filter.to/#{size}/#{path}"

dropProtocol = (path)-> path.replace /^(https?:)?\/\//, ''



exports.placeholder = (height=250, width=200)->  _.placeholder(height, width)