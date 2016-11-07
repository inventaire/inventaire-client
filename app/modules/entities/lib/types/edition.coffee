{ unprefixifyEntityId } = require 'lib/wikimedia/wikidata'
wdLang = require 'wikidata-lang'
farInTheFuture = '2100'

module.exports = ->
  langUri = @get('claims.wdt:P407.0')
  lang = if langUri then wdLang.byWdId[unprefixifyEntityId(langUri)]?.code

  publicationTime = new Date(@get('claims.wdt:P577.0') or farInTheFuture).getTime()

  workUri = @get 'claims.wdt:P629.0'

  @waitForWork = @reqGrab 'get:entity:model', workUri, 'work'
  .tap setLabel.bind(@)

  @set
    lang: lang
    publicationTime: publicationTime

  _.extend @, editionMethods

setLabel = (work)->
  unless @get('label')? then @set 'label', @work.get('label')

editionMethods =
  getAuthorsString: -> @waitForWork.then (work)-> work.getAuthorsString()
  buildWorkTitle: -> @waitForWork.then (work)-> work.buildWorkTitle()
