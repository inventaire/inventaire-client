getBestLangValue = sharedLib('get_best_lang_value')(_)

module.exports = Backbone.Model.extend
  initialize: (attrs)->
    @set typeFormatters[attrs._type](attrs)

entityFormatter = (type, typeAlias)-> (attrs)->
  data = attrs._source
  prefix = if attrs._index is 'wikidata' then 'wd' else 'inv'
  uri = "#{prefix}:#{data.id}"
  # TODO: recover claims OR keep an index of entities best images (per-language?)
  pathname = "/entity/#{uri}"
  image = data.claims?['wdt:P18']?[0]
  label = getBestLangValue(app.user.lang, null, data.labels).value
  description = getBestLangValue(app.user.lang, null, data.descriptions).value
  showCommand = 'show:entity'
  typeAlias = typeAlias or type
  return { pathname, uri, type, typeAlias, image, label, description, showCommand }

typeFormatters =
  works: entityFormatter 'work', 'book'
  humans: entityFormatter 'author'
  series: entityFormatter 'serie'
  users: (attrs)->
    data = attrs._source
    return {
      type: 'user'
      typeAlias: 'user'
      label: data.username
      pathname: "/inventory/#{data.username}"
      image: data.picture
      description: data.bio
      showCommand: 'show:inventory:user'
    }

  groups: (data)->
    data = attrs._source
    return {
      type: 'group'
      typeAlias: 'group'
      pathname: "/groups/#{data.slug}"
      label: data.name
      image: data.picture
      description: data.description
      showCommand: 'show:inventory:group:byId'
    }
