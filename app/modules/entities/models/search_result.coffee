Filterable = require 'modules/general/models/filterable'
getBestLangValue = sharedLib('get_best_lang_value')(_)
wdk = require 'lib/wikidata-sdk'
error_ = require 'lib/error'

# make models use 'id' as idAttribute so that search results
# automatically deduplicate themselves
module.exports = Filterable.extend
  idAttribute: 'id'
  initialize: ->
    { lang } = app.user

    [ labels, descriptions ] = @gets 'labels', 'descriptions'
    if labels? then @set 'label', getBestLangValue(lang, null, labels)
    if descriptions? then @set 'description', getBestLangValue(lang, null, descriptions)

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
    labels = _.values @get('labels')
    descriptions = _.values @get('descriptions')
    aliases = _.flatten _.values(@get('aliases'))
    @_values = [ @id ].concat labels, aliases, descriptions
    return @_values

# Search results arrive as either Wikidata or inventaire documents
# with ids unprefixed. The solutions to fix it:
# * formatting search documents to include prefixes
# * guessing which source the document belongs too from what we get
# For the moment, let's keep it easy and use the 2nd solution
getPrefix = (id)->
  if wdk.isWikidataEntityId id then return ['wd', id]
  else if _.isInvEntityId id then return ['inv', id]
  else throw error_.new('unknown id domain', {id: id})
