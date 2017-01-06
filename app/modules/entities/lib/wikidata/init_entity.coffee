sitelinks_ = require 'lib/wikimedia/sitelinks'
wikipedia_ = require 'lib/wikimedia/wikipedia'
getBestLangValue = sharedLib('get_best_lang_value')(_)
{ escapeExpression } = Handlebars

module.exports = ->
  { lang } = app.user
  setWikiLinks.call @, lang
  setAttributes.call @, lang

  waitForExtract = setWikipediaExtract.call @
  @_dataPromises.push waitForExtract

setWikiLinks = (lang)->
  updates =
    wikidata:
      url: "https://www.wikidata.org/entity/#{@wikidataId}"
      wiki: "https://www.wikidata.org/wiki/#{@wikidataId}"

  # Editions happen on Wikidata for now
  updates.edit = updates.wikidata.wiki

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

  description = getBestLangValue lang, @originalLang, @get('descriptions')
  if description?
    # This may be overriden by a Wikipedia extract
    # Escaping as description are user-generated external content
    # that will be displayed as {{{SafeStrings}}} in views as
    # they may be enriched with HTML (see app/lib/wikimedia/wikipedia)
    @set 'description', escapeExpression(description)
    # This stays the same in any case
    @set 'shortDescription', description

setWikipediaExtract = ->
  lang = @get 'wikipedia.lang'
  title = @get 'wikipedia.title'
  unless lang? and title? then return _.preq.resolved

  wikipedia_.extract lang, title
  .then _setWikipediaExtractAndDescription.bind(@)
  .catch _.Error('setWikipediaExtract err')

_setWikipediaExtractAndDescription = (extract)->
  if extract?
    @set 'extract', extract
    description = @get('description') or ''
    if extract.length > description.length
      @set 'description', extract
