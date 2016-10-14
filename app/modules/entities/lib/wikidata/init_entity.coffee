sitelinks_ = require 'lib/wikimedia/sitelinks'
wikipedia_ = require 'lib/wikimedia/wikipedia'
getBestLangValue = require '../get_best_lang_value'

module.exports = ->
  { lang } = app.user
  setWikiLinks.call @, lang
  setAttributes.call @, lang

  waitForExtract = setWikipediaExtract.call @, lang
  @_dataPromises.push waitForExtract

setWikiLinks = (lang)->
  updates =
    wikidata:
      url: "https://www.wikidata.org/entity/#{@id}"
      wiki: "https://www.wikidata.org/wiki/#{@id}"

  sitelinks = @get 'sitelinks'
  if sitelinks?
    # required to fetch images from the English Wikipedia
    @enWpTitle = sitelinks.enwiki
    updates.wikipedia = sitelinks_.wikipedia sitelinks, lang, @originalLang
    updates.wikisource = sitelinks_.wikisource sitelinks, lang, @originalLang

  @set updates

setWikipediaExtract = (lang)->
  title = @get 'wikipedia.title'
  unless title? then return _.preq.resolved

  wikipedia_.extract lang, title
  .then (extract)=> if extract? then @set 'extract', extract
  .catch _.Error('setWikipediaExtract err')

setAttributes = (lang)->
  label = @get 'label'
  wikipediaTitle = @get 'wikipedia.title'
  if wikipediaTitle? and not label?
    # If no label was found, try to use the wikipedia page title
    # remove the escaped spaces: %20
    label = decodeURIComponent wikipediaTitle
      # Remove the eventual desambiguation part between parenthesis
      .replace /\s\(\w+\)/, ''

    @set 'label', label

  description = getBestLangValue lang, @originalLang, @get('descriptions')
  if description? then @set 'description', description
