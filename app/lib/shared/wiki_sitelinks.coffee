module.exports =
  wikipedia: (sitelinks, lang)->
    return getBestWikiProjectInfo sitelinks, 'wiki', 'wikipedia', lang, @originalLang

  wikisource: (sitelinks, lang)->
    wsData = getBestWikiProjectInfo sitelinks, 'wikisource', 'wikisource', lang, @originalLang
    wsData.epub = getEpubLink wsData
    return wsData


getBestWikiProjectInfo = (sitelinks, projectBaseName, projectRoot, lang, originalLang)->
  getTitleForLang = (Lang)-> getWikiProjectTitle sitelinks, projectBaseName, Lang

  [title, L] = [getTitleForLang(lang), lang]

  if originalLang? and not title?
    [title, L] = [getTitleForLang(originalLang), originalLang]

  unless title?
    [title, L] = [getTitleForLang('en'), 'en']

  unless title?
    [title, L] = pickOneWikiProjectTitle(sitelinks, projectBaseName)

  if title? and L
    url = "https://#{L}.#{projectRoot}.org/wiki/#{title}"
    return {title: title, lang: L, url: encodeURI(url)}

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
      L = match[0]
      return [v.title, L]
  return []

getEpubLink = (wikisourceData)->
  { title, lang } = wikisourceData
  return "http://wsexport.wmflabs.org/tool/book.php?lang=#{lang}&format=epub&page=#{title}"
