{ SafeString } = Handlebars

exports.icon = (name, classes) ->
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
  pouchdb: '/public/images/pouchdb.svg'

imagesList = Object.keys images

exports.iconLink = (name, url, classes)->
  icon = @icon.call null, name, classes
  return @link.call @, icon, url, ''

exports.iconLinkText = (name, url, text, classes)->
  icon = @icon.call null, name, classes
  return @link.call @, "#{icon}<span>#{text}</span>", url, ''
