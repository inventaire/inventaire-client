{ unprefixifyEntityId } = require 'lib/wikimedia/wikidata'
wdLang = require 'wikidata-lang'
farInTheFuture = '2100'

module.exports = ->
  langUri = @get('claims.wdt:P407.0')
  lang = if langUri then wdLang.byWdId[unprefixifyEntityId(langUri)]?.code

  publicationTime = new Date(@get('claims.wdt:P577.0') or farInTheFuture).getTime()

  workUri = @get 'claims.wdt:P629.0'

  # Editions don't have subentities so the list of all their uris,
  # including their subentities, are limited to their own uri
  @set 'allUris', [ @get('uri') ]
  # No subentities to fetch
  @waitForSubentities = _.preq.resolved

  @set
    lang: lang
    publicationTime: publicationTime
    # Take the label from the monolingual title property
    label: @get 'claims.wdt:P1476.0'

  @waitForWork = @reqGrab 'get:entity:model', workUri, 'work'
  .tap inheritData.bind(@)

  _.extend @, specificMethods

  return

# Editions inherit claims like author 'wdt:P50' from their work
inheritData = (work)->
  unless @get('label')? then @set 'label', @work.get('label')
  claims = @get 'claims'
  workClaims = work.get 'claims'
  @set 'claims', _.extend({}, workClaims, claims)

specificMethods =
  getAuthorsString: -> @waitForWork.then (work)-> work.getAuthorsString()
  buildTitleAsync: -> @waitForWork.then (work)-> work.buildTitle()
