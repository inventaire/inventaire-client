wd_ = require 'lib/wikimedia/wikidata'

module.exports = (typesString, defaultTypeString)->
  buildTitle: ->
    title = @get 'label'
    P31 = @get 'claims.wdt:P31.0'
    type = _.I18n(typesString[P31] or 'book')
    return "#{title} - #{type}"
