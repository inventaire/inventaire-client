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
  pouchdb: 'http://pouchdb.com/static/img/mark.svg'

exports.iconLink = (name, url, classes)->
  icon = @icon.call null, name, classes
  return @link.call @, icon, url

exports.iconLinkText = (name, url, text, classes)->
  icon = @icon.call null, name, classes
  return @link.call @, "#{icon}<span>#{text}</span>", url
