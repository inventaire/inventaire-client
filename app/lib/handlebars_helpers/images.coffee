{ SafeString } = Handlebars

exports.icon = (name, classes)->
  if _.isString(name)
    if name in imagesList
      src = images[name]
      return new SafeString "<img class='icon' src='#{src}'>"
    else
      # overriding the second argument that could be {hash:,data:}
      unless _.isString classes then classes = ''
      return new SafeString _.icon(name, classes)

images =
  wikipedia: '/public/images/wikipedia-64.png'
  wikidata: '/public/images/wikidata.svg'
  wikisource: '/public/images/wikisource-64.png'
  'barcode-scanner': '/public/images/barcode-scanner-64.png'

imagesList = Object.keys images

exports.iconLink = (name, url, classes)->
  icon = @icon.call null, name, classes
  return @link.call @, icon, url, ''

exports.iconLinkText = (name, url, text, classes)->
  if _.isObject name.hash
    { name, url, classes, text, i18n, I18n, i18nArgs } = name.hash
    # Expect i18nArgs to be a string formatted as a querystring
    i18nArgs = _.parseQuery i18nArgs
    if I18n? then text = _.I18n I18n, i18nArgs
    else if i18n? then text = _.i18n i18n, i18nArgs

  icon = @icon.call null, name, classes
  return @link.call @, "#{icon}<span>#{text}</span>", url, ''
