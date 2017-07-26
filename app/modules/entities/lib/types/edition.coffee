{ unprefixify } = require 'lib/wikimedia/wikidata'
wdLang = require 'wikidata-lang'
farInTheFuture = '2100'

module.exports = ->
  _.extend @, specificMethods
  @setClaimsBasedAttributes()

  uri = @get 'uri'
  # Works is pluralized to account for composite editions
  # cf https://github.com/inventaire/inventaire/issues/93
  worksUris = @get 'claims.wdt:P629'
  unless worksUris?
    throw new Error("entity #{uri} misses an associated work")

  # Editions don't have subentities so the list of all their uris,
  # including their subentities, are limited to their own uri
  @set 'allUris', [ uri ]

  # No subentities to fetch
  @waitForSubentities = _.preq.resolved

  @waitForWorks = @reqGrab 'get:entities:models', { uris: worksUris }, 'works'
  # Use tap to ignore the return values
  .tap inheritData.bind(@)
  # Got to be initialized after inheritData is run to avoid running
  # several times at initialization
  .tap startListeningForClaimsChanges.bind(@)

  return

# Editions inherit some claims from their work but not all, as it could get confusing.
# Ex: publication date should not be inherited
inheritData = (works)->
  # Use cases: used on the edition layout to display authors and series
  setWorksClaims.call @, works, 'wdt:P50'
  setWorksClaims.call @, works, 'wdt:P179'
  return

setWorksClaims = (works, property)->
  values = _.uniq _.flatten(works.map((work)-> work.get("claims.#{property}")))
  @set "claims.#{property}", values

startListeningForClaimsChanges = ->
  @on 'change:claims', @setClaimsBasedAttributes.bind(@)
  # Do no return the event listener return value as it makes Bluebird crash
  # (at least when passed to a .then)
  return

specificMethods =
  buildTitleAsync: ->
    title = @get 'claims.wdt:P1476.0'
    if title then _.preq.resolve title
    # Legacy: all editions are now expected to have a title (wdt:P1476) claim
    else @waitForWorks.then (works)-> works.map((work)-> work.buildTitle()).join(' / ')

  setLang: ->
    langUri = @get 'claims.wdt:P407.0'
    lang = if langUri then wdLang.byWdId[unprefixify(langUri)]?.code
    @set 'lang', lang

  setLabelFromTitle: ->
    # Take the label from the monolingual title property
    @set 'label', @get('claims.wdt:P1476.0')

  setPublicationTime: ->
    publicationDate = @get 'claims.wdt:P577.0'
    publicationTime = new Date(publicationDate or farInTheFuture).getTime()
    @set 'publicationTime', publicationTime

  setClaimsBasedAttributes: ->
    @setLang()
    @setLabelFromTitle()
    @setPublicationTime()
    @set 'isCompositeEdition', (@get('claims.wdt:P629')?.length > 1)
