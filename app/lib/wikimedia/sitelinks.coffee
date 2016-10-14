# lang: the user's lang
# original lang: the entity's original lang

module.exports =
  wikipedia: (sitelinks, lang, originalLang)->
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

getWikiProjectTitle = (sitelinks, projectBaseName, lang)-> sitelinks["#{lang}#{projectBaseName}"]

pickOneWikiProjectTitle = (sitelinks, projectBaseName)->
  for projectName, value of sitelinks
    match = projectName.split projectBaseName
    # ex: 'lawikisource'.split 'wikisource' == ['la', '']
    if match.length is 2
      langCode = match[0]
      return [value, langCode]
  return []

getEpubLink = (wikisourceData)->
  { title, lang } = wikisourceData
  return "http://wsexport.wmflabs.org/tool/book.php?lang=#{lang}&format=epub&page=#{title}"
