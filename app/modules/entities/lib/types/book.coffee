module.exports = ->
  # Main property by which sub-entities are linked to this one
  @childrenClaimProperty = 'wdt:P629'
  @fetchSubEntities @refresh

  setPublicationYear.call @

  _.extend @, bookMethods

setPublicationYear = ->
  publicationDate = @get('claims.wdt:P577')?[0]
  if publicationDate?
    @publicationYear = publicationDate.split('-')[0]

bookMethods =
  getAuthorsString: ->
    P50 = @get('claims.wdt:P50')
    unless P50?.length > 0 then return _.preq.resolve ''
    return wd_.getLabel P50, app.user.lang

  buildBookTitle: (type)->
    title = @get 'label'
    return "#{title} - " + _.I18n type
