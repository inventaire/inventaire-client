sitelinks_ = require 'lib/wikimedia/sitelinks'
wikipedia_ = require 'lib/wikimedia/wikipedia'
getBestLangValue = require 'modules/entities/lib/get_best_lang_value'
{ escapeExpression } = Handlebars
wdHost = 'https://www.wikidata.org'

module.exports = ->
  { lang } = app.user
  setWikiLinks.call @, lang
  setAttributes.call @, lang

  _.extend @, specificMethods

setWikiLinks = (lang)->
  updates =
    wikidata:
      url: "#{wdHost}/entity/#{@wikidataId}"
      wiki: "#{wdHost}/wiki/#{@wikidataId}"
      history: "#{wdHost}/w/index.php?title=#{@wikidataId}&action=history"

  sitelinks = @get 'sitelinks'
  if sitelinks?
    updates.wikipedia = sitelinks_.wikipedia sitelinks, lang, @originalLang
    updates.wikisource = sitelinks_.wikisource sitelinks, lang, @originalLang

  @set updates

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

  description = getBestLangValue(lang, @originalLang, @get('descriptions')).value
  if description? then @set 'description', description

specificMethods =
  getWikipediaExtract: ->
    # If an extract was already fetched, we are done
    if @get('extract')? then return Promise.resolve()

    lang = @get 'wikipedia.lang'
    title = @get 'wikipedia.title'
    unless lang? and title? then return Promise.resolve()

    wikipedia_.extract lang, title
    .then _setWikipediaExtractAndDescription.bind(@)
    .catch _.Error('setWikipediaExtract err')

_setWikipediaExtractAndDescription = (extractData)->
  { extract, lang } = extractData
  if _.isNonEmptyString extract
    extractDirection = if lang in rtlLang then 'rtl' else 'ltr'
    @set 'extractDirection', extractDirection
    @set 'extract', extract

rtlLang = [ 'ar', 'he' ]
