publicDomainThresholdYear = new Date().getFullYear() - 70
commonsSerieWork = require './commons_serie_work'
filterOutWdEditions = require '../filter_out_wd_editions'
getEntityItemsByCategories = require '../get_entity_items_by_categories'

module.exports = ->
  # Main property by which sub-entities are linked to this one: edition of
  @childrenClaimProperty = 'wdt:P629'
  # inverse property: edition(s)
  @subEntitiesInverseProperty = 'wdt:P747'

  @usesImagesFromSubEntities = true

  @subentitiesName = 'editions'
  # extend before fetching sub entities to have access
  # to the custom @beforeSubEntitiesAdd
  _.extend @, specificMethods

  setPublicationYear.call @
  setEbooksData.call @

setPublicationYear = ->
  publicationDate = @get 'claims.wdt:P577.0'
  if publicationDate?
    @publicationYear = parseInt publicationDate.split('-')[0]
    @inPublicDomain = @publicationYear < publicDomainThresholdYear

setImage = ->
  editionsImages = _.compact @editions.map(getEditionImageData)
    .sort bestImage
    .map _.property('image')

  workImage = @get 'image'
  # If the work is in public domain, we can expect Wikidata image to be better
  # if there is one. In any other case, prefer images from editions
  # as illustration from Wikidata for copyrighted content can be quite random.
  # Wikipedia and OpenLibrary work images follow the same rule for simplicity
  if workImage? and @inPublicDomain
    images = [ workImage ].concat editionsImages
  else
    images = editionsImages
    @set 'image', (images[0] or workImage)

  @set 'images', images.slice(0, 3)

getEditionImageData = (model)->
  image = model.get 'image'
  unless image?.url? then return
  return {
    image: image
    lang: model.get 'lang'
    publicationDate: model.get 'publicationTime'
    isCompositeEdition: model.get 'isCompositeEdition'
  }

bestImage = (a, b)->
  { lang:userLang } = app.user
  if a.isCompositeEdition isnt b.isCompositeEdition
    if a.isCompositeEdition then 1
    else -1
  else if a.lang is b.lang then latestPublication a, b
  else if a.lang is userLang then -1
  else if b.lang is userLang then 1
  else latestPublication a, b

latestPublication = (a, b)-> b.publicationTime - a.publicationTime

setEbooksData = ->
  hasInternetArchivePage = @get('claims.wdt:P724.0')?
  hasGutenbergPage = @get('claims.wdt:P2034.0')?
  hasWikisourcePage = @get('wikisource.url')?
  @set 'hasEbooks', (hasInternetArchivePage or hasGutenbergPage or hasWikisourcePage)
  @set 'gutenbergProperty', 'wdt:P2034'

specificMethods = _.extend {}, commonsSerieWork,
  # wait for setImage to have run
  getImageAsync: -> @fetchSubEntities().then => @get 'image'
  getItemsByCategories: getEntityItemsByCategories
  beforeSubEntitiesAdd: filterOutWdEditions
  afterSubEntitiesAdd: setImage
