wd_ = require 'lib/wikimedia/wikidata'

module.exports = (typesString, defaultTypeString)->
  getAuthorsString: ->
    P50 = @get 'claims.wdt:P50'
    unless P50?.length > 0 then return _.preq.resolve ''
    return wd_.getLabel P50, app.user.lang

  buildTitle: ->
    title = @get 'label'
    P31 = @get 'claims.wdt:P31.0'
    type = _.I18n(typesString[P31] or 'book')
    return "#{title} - #{type}"
