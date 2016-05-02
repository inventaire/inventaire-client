Filterable = require 'modules/general/models/filterable'
getBestLangValue = require '../lib/get_best_lang_value'

# make models use 'id' as idAttribute so that search results
# automatically dedupplicate themselves
module.exports = Filterable.extend
  idAttribute: 'id'
  initialize: ->
    { lang } = app.user
    label = getBestLangValue lang, null, @get('labels')
    description = getBestLangValue lang, null, @get('descriptions')

    @set
      url: "//wikidata.org/entity/#{@id}"
      label: label
      description: description

  asMatchable: ->
    if @_values? then return @_values
    labels = _.values @get('labels')
    aliases = _.flatten _.values(@get('aliases'))
    return @_values = [ @id ].concat labels, aliases
