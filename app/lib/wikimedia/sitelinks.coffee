{ buildPath } = require 'lib/location'

module.exports =
  # lang: the user's lang
  # original lang: the entity's original lang
  wikipedia: (sitelinks, lang, originalLang)->
    # Wikimedia Commons is confusingly using a sitelink key that makes it look like
    # a Wikipedia sitelink - commonswiki - thus the need to omit it before proceeding
    # https://www.wikidata.org/wiki/Help:Sitelinks#Linking_to_Wikimedia_site_pages
    sitelinks = _.omit sitelinks, 'commonswiki'
    getBestWikiProjectInfo
      sitelinks: sitelinks
      projectBaseName: 'wiki'
      projectRoot: 'wikipedia'
      lang: lang
      originalLang: originalLang

  wikisource: (sitelinks, lang, originalLang)->
    wsData = getBestWikiProjectInfo
      sitelinks: sitelinks
      projectBaseName: 'wikisource'
      projectRoot: 'wikisource'
      lang: lang
      originalLang: originalLang
    if wsData?
      wsData.epub = getEpubLink wsData
      return wsData

getBestWikiProjectInfo = (params)->
  { sitelinks, projectBaseName, projectRoot, lang, originalLang } = params
  unless sitelinks? then return

  getTitleForLang = (Lang)-> getWikiProjectTitle sitelinks, projectBaseName, Lang

  [ title, langCode ] = [ getTitleForLang(lang), lang ]

  if originalLang? and not title?
    [ title, langCode ] = [ getTitleForLang(originalLang), originalLang ]

  unless title?
    [ title, langCode ] = [ getTitleForLang('en'), 'en' ]

  unless title?
    [ title, langCode ] = pickOneWikiProjectTitle(sitelinks, projectBaseName)

  if title? and langCode
    title = _.fixedEncodeURIComponent title
    url = "https://#{langCode}.#{projectRoot}.org/wiki/#{title}"
    return { title, lang: langCode, url }

  return

getWikiProjectTitle = (sitelinks, projectBaseName, lang)->
  sitelinks["#{lang}#{projectBaseName}"]

pickOneWikiProjectTitle = (sitelinks, projectBaseName)->
  for projectName, value of sitelinks
    match = projectName.split projectBaseName
    # ex: 'lawikisource'.split 'wikisource' == ['la', '']
    # The second part needs to be an empty string to avoid confusing
    # a sitelink like : for dewiki
    if match.length is 2 and match[1] is ''
      langCode = match[0]
      # Giving priority to 2 letters code languages
      if langCode.length is 2 then return [ value, langCode ]

  return []

getEpubLink = (wikisourceData)->
  { title, lang } = wikisourceData
  buildPath 'http://wsexport.wmflabs.org/tool/book.php',
    lang: lang
    format: 'epub'
    page: title
