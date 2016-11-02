wd_ = require 'lib/wikimedia/wikidata'

module.exports = ->
  # Main property by which sub-entities are linked to this one
  @childrenClaimProperty = 'wdt:P629'
  @fetchSubEntities 'editions', @refresh

  setPublicationYear.call @

  _.extend @, workMethods

setPublicationYear = ->
  publicationDate = @get('claims.wdt:P577')?[0]
  if publicationDate?
    @publicationYear = publicationDate.split('-')[0]

workMethods =
  getAuthorsString: ->
    P50 = @get('claims.wdt:P50')
    unless P50?.length > 0 then return _.preq.resolve ''
    return wd_.getLabel P50, app.user.lang

  buildWorkTitle: ->
    title = @get 'label'
    P31 = @get 'claims.wdt:P31.0'
    type = _.I18n(P31 or 'book')
    return "#{title} - #{type}"
