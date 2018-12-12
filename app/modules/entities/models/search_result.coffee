Filterable = require 'modules/general/models/filterable'
getBestLangValue = require 'modules/entities/lib/get_best_lang_value'
wdk = require 'lib/wikidata-sdk'
error_ = require 'lib/error'

# make models use 'id' as idAttribute so that search results
# automatically deduplicate themselves
module.exports = Filterable.extend
  idAttribute: 'id'
  initialize: ->
    { lang } = app.user

    [ labels, descriptions ] = @gets 'labels', 'descriptions'

    if labels?
      @set 'label', getBestLangValue(lang, null, labels).value

    if descriptions?
      @set 'description', getBestLangValue(lang, null, descriptions).value

    [ prefix ] = getPrefix @id

    switch prefix
      when 'wd' then @_wikidataInit()
      when 'inv' then @_invInit()

  _wikidataInit: ->
    @set
      uri: "wd:#{@id}"
      url: "https://wikidata.org/entity/#{@id}"

  _invInit: ->
    @set
      uri: "inv:#{@id}"
      url: "/entity/#{@id}"

  matchable: ->
    if @_values? then return @_values
    labels = getValues @get('labels')
    descriptions = getValues @get('descriptions')
    aliases = _.flatten getValues(@get('aliases'))
    uris = [ @id, @get('uri') ]
    @_values = [ @id ].concat labels, aliases, descriptions, uris
    return @_values

getValues = (obj)-> if obj? then _.values(obj) else []

# Search results arrive as either Wikidata or inventaire documents
# with ids unprefixed. The solutions to fix it:
# * formatting search documents to include prefixes
# * guessing which source the document belongs too from what we get
# For the moment, let's keep it easy and use the 2nd solution
getPrefix = (id)->
  if wdk.isWikidataItemId id then return ['wd', id]
  else if _.isInvEntityId id then return ['inv', id]
  else throw error_.new 'unknown id domain', { id }
