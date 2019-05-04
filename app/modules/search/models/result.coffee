getBestLangValue = require 'modules/entities/lib/get_best_lang_value'

module.exports = Backbone.Model.extend
  initialize: (data)->
    # Track TypeErrors where typeFormatters[data.type] isn't a function
    try @set typeFormatters[data.type](data)
    catch err
      err.context = { data }
      throw err

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
    # Let app/lib/shared/api/img.coffee request to be redirected
    # to the associated entity image
    data.image = data.uri
    return data
