getBestLangValue = sharedLib('get_best_lang_value')(_)

module.exports = Backbone.Model.extend
  initialize: (data)->
    @set typeFormatters[data.type](data)

entityFormatter = (type, typeAlias)-> (data)->
  data.typeAlias = typeAlias or type
  data.pathname = "/entity/#{data.uri}"
  return data

typeFormatters =
  works: entityFormatter 'work', 'book'
  humans: entityFormatter 'author'
  series: entityFormatter 'serie'
  users: (data)->
    data.typeAlias = 'user'
    # label is the username
    data.pathname = "/inventory/#{data.label}"
    return data

  groups: (data)->
    data.typeAlias = 'group'
    data.pathname = "/groups/#{data.id}"
    return data

  subjects: (data)->
    data.typeAlias = 'subject'
    data.pathname = "/entity/wdt:P921-#{data.uri}"
    return data
