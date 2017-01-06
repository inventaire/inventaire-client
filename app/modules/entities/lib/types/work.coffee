wd_ = require 'lib/wikimedia/wikidata'
publicDomainThresholdYear = new Date().getFullYear() - 70

module.exports = ->
  # Main property by which sub-entities are linked to this one: edition of
  @childrenClaimProperty = 'wdt:P629'
  # inverse property: edition(s)
  @childrenInverseProperty = 'wdt:P747'

  @subentitiesName = 'editions'
  @fetchSubEntities @refresh

  setPublicationYear.call @
  setEbooksData.call @
  @waitForSubentities.then setImage.bind(@)

  _.extend @, specificMethods

setPublicationYear = ->
  publicationDate = @get 'claims.wdt:P577.0'
  if publicationDate?
    @publicationYear = parseInt publicationDate.split('-')[0]
    @inPublicDomain = @publicationYear < publicDomainThresholdYear

setImage = ->
  images =_.compact @editions.map(getEditionImageData)
  images.sort BestImage(app.user.lang)
  currentImage = @get('image')
  candidateImage = images[0]?.image
  # If the work is in public domain, we can expect Wikidata image to be better
  # if there is one. In any other case, prefer images from editions
  # as illustration from Wikidata for copyrighted content can be quite random.
  # Wikipedia and OpenLibrary work images follow the same rule for simplicity
  if currentImage? and @inPublicDomain then return
  else @set 'image', (candidateImage or currentImage)

getEditionImageData = (model)->
  image = model.get 'image'
  unless image?.url? then return
  return {
    image: image
    lang: model.get 'lang'
    publicationDate: model.get 'publicationTime'
  }

# Sorting function on probation
BestImage = (userLang)-> (a, b)->
  if a.lang is b.lang then latestPublication a, b
  else if a.lang is userLang then -1
  else if b.lang is userLang then 1
  else latestPublication a, b

latestPublication = (a, b)-> b.publicationTime - a.publicationTime

setEbooksData = ->
  hasGutenbergPage = @get('claims.wdt:P2034.0')?
  hasWikisourcePage = @get('wikisource.url')?
  @set 'hasEbooks', (hasGutenbergPage or hasWikisourcePage)
  @set 'gutenbergProperty', 'wdt:P2034'

specificMethods =
  getAuthorsString: ->
    P50 = @get 'claims.wdt:P50'
    unless P50?.length > 0 then return _.preq.resolve ''
    return wd_.getLabel P50, app.user.lang

  buildTitle: ->
    title = @get 'label'
    P31 = @get 'claims.wdt:P31.0'
    type = _.I18n(typesString[P31] or 'book')
    return "#{title} - #{type}"

typesString =
  'wd:Q571': 'book'
  'wd:Q1004': 'comic book'
  'wd:Q8274': 'manga'
  'wd:Q49084': 'short story'
