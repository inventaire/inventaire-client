wd_ = require 'lib/wikimedia/wikidata'

module.exports = (typesString, defaultTypeString)->
  buildTitle: ->
    title = @get 'label'
    P31 = @get 'claims.wdt:P31.0'
    type = _.I18n(typesString[P31] or 'book')
    return "#{title} - #{type}"

  getExtendedAuthorsModels: ->
    Promise.props
      'wdt:P50': @getModelsFromClaims 'wdt:P50'
      'wdt:P58': @getModelsFromClaims 'wdt:P58'
      'wdt:P110': @getModelsFromClaims 'wdt:P110'
      'wdt:P6338': @getModelsFromClaims 'wdt:P6338'

  getModelsFromClaims: (property)->
    uris = @get "claims.#{property}"
    if uris?.length > 0 then app.request 'get:entities:models', { uris }
    else _.preq.resolve []

authorProperties = [
  'wdt:P50'
  'wdt:P58'
  'wdt:P110'
  'wdt:P6338'
]
