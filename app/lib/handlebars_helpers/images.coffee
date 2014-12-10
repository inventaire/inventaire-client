module.exports =
  icon: (name, classes) ->
    if _.isString(name)
      if icons[name]?
        src = icons[name]
        return new Handlebars.SafeString "<img class='icon svg' src='#{src}'>"
      else
        # overriding the second argument that could be {hash:,data:}
        unless _.isString classes then classes = ''
        return new Handlebars.SafeString "<i class='fa fa-#{name} #{classes}'></i>&nbsp;&nbsp;"

  # filter.to documentation: http://cdn.filter.to/faq/
  src: (path, width, height, extend)->
    return ''  unless path?

    # testing with isNumber due to {data:,hash: }
    # being added as last argument
    return path  unless _.isNumber(width)

    if /gravatar.com/.test(path)
      # removing any size parameter
      path = path.replace /&s=\d+/g, ''
      return path + "&s=#{width}"
    else
      unless _.isNumber(height) then height = width
      size = "#{width}x#{height}"
      unless extend then size += 'g'
      # removing the protocol
      path = path.replace /^((http|https):)\/\//, ''
      return "http://cdn.filter.to/#{size}/#{path}"

  placeholder: (height=250, width=200)->  _.placeholder(height, width)

icons =
  wikipedia: 'https://upload.wikimedia.org/wikipedia/en/8/80/Wikipedia-logo-v2.svg'
  wikidata: 'https://upload.wikimedia.org/wikipedia/commons/f/ff/Wikidata-logo.svg'
  wikidataWhite: 'http://img.inventaire.io/Wikidata-logo-white.svg'
  wikisource: 'https://upload.wikimedia.org/wikipedia/commons/4/4c/Wikisource-logo.svg'