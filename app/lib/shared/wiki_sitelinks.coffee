module.exports =
  wikipedia: (sitelinks, lang)->
    return getBestWikiProjectInfo sitelinks, 'wiki', 'wikipedia', lang, @originalLang

  wikisource: (sitelinks, lang)->
    wsData = getBestWikiProjectInfo sitelinks, 'wikisource', 'wikisource', lang, @originalLang
    if wsData?
      wsData.epub = getEpubLink wsData
      return wsData


getBestWikiProjectInfo = (sitelinks, projectBaseName, projectRoot, lang, originalLang)->
  getTitleForLang = (Lang)-> getWikiProjectTitle sitelinks, projectBaseName, Lang

  [ title, langCode ] = [ getTitleForLang(lang), lang ]

  if originalLang? and not title?
    [ title, langCode ] = [ getTitleForLang(originalLang), originalLang ]

  unless title?
    [ title, langCode ] = [ getTitleForLang('en'), 'en' ]

  unless title?
    [ title, langCode ] = pickOneWikiProjectTitle(sitelinks, projectBaseName)

  if title? and langCode
    title = encodeURIComponent title
    url = "https://#{langCode}.#{projectRoot}.org/wiki/#{title}"
    return {title: title, lang: langCode, url: url}

  return

getWikiProjectTitle = (sitelinks, projectBaseName, lang)->
  link = sitelinks?["#{lang}#{projectBaseName}"]
  if link?.title? then return link.title
  return

pickOneWikiProjectTitle = (sitelinks, projectBaseName)->
  for k,v of sitelinks
    match = k.split(projectBaseName)
    # ex: 'lawikisource'.split 'wikisource' == ['la', '']
    if match.length is 2
      langCode = match[0]
      return [v.title, langCode]
  return []

getEpubLink = (wikisourceData)->
  { title, lang } = wikisourceData
  return "http://wsexport.wmflabs.org/tool/book.php?lang=#{lang}&format=epub&page=#{title}"
