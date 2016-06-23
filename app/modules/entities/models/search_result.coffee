Filterable = require 'modules/general/models/filterable'
getBestLangValue = require '../lib/get_best_lang_value'
wdk = require 'wikidata-sdk'
error_ = require 'lib/error'

# make models use 'id' as idAttribute so that search results
# automatically dedupplicate themselves
module.exports = Filterable.extend
  idAttribute: 'id'
  initialize: ->
    { lang } = app.user

    @set
      label: getBestLangValue lang, null, @get('labels')
      description: getBestLangValue lang, null, @get('descriptions')

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
    aliases = _.flatten _.values(@get('aliases'))
    return @_values = [ @id ].concat labels, aliases


# Search results arrive as either Wikidata or inventaire documents
# with ids unprefixed. To solutions to fix it:
# * formatting search documents to include prefixes
# * guessing which source the document belongs too from what we get
# For the moment, let's keep it easy and use the 2nd solution
getPrefix = (id)->
  if wdk.isWikidataEntityId id then return ['wd', id]
  else if _.isUuid id then return ['inv', id]
  else throw error_.new 'unknown id domain', id
