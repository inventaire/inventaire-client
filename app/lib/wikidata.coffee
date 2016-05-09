aliases = sharedLib 'wikidata_aliases'
preq = requireProxy 'lib/preq'

module.exports = wd_ = sharedLib('wikidata')(preq, _, wdk)

# more complete data access: can include author and license
wd_.wmCommonsThumbData = (file, width=500)->
  width = _.bestImageWidth width
  preq.get app.API.data.commonsThumb(file, width)

wd_.wmCommonsThumb = (file, width=500)->
  wd_.wmCommonsThumbData file, width
  .then _.property('thumbnail')
  .catch (err)->
    console.warn "couldnt find #{file} via tools.wmflabs.org, will use the small thumb version"
    return wd_.wmCommonsSmallThumb file, 200

wd_.enWpImage = (enWpTitle)->
  preq.get app.API.data.enWpImage enWpTitle
  .then _.property('url')
  .catch _.ErrorRethrow('enWpImage err')

wd_.wikipediaExtract = (lang, title)->
  preq.get app.API.data.wikipediaExtract(lang, title)
  .then (data)->
    { extract, url } = data
    return sourcedExtract extract, url
  .catch _.ErrorRethrow('wikipediaExtract err')

# add a link to the full wikipedia article at the end of the extract
sourcedExtract = (extract, url)->
  if url?
    text = _.i18n 'read_more_on_wikipedia'
    return extract += "<br><a href='#{url}' class='source link' target='_blank'>#{text}</a>"
  else extract

# wd_.normalizeTime = wdk.normalizeWikidataTime
wd_.sitelinks = sharedLib 'wiki_sitelinks'

wd_.aliasingClaims = (claims)->
  for id, claim of claims
    # if this Property could be assimilated to another Property
    # add this Property values to the main one
    aliasId = aliases[id]
    if aliasId?
      before = claims[aliasId] or= []
      aliased = claims[id]
      try
        # uniq can not test uniqueness on objects
        _.types before, 'strings...|numbers...'
        _.types aliased, 'strings...|numbers...'
        after = _.uniq before.concat(aliased)
        # _.log [aliasId, before, id, aliased, aliasId, after], 'entity aliasingClaims'
        claims[aliasId] = after
      catch err
        _.warn [err, id, claim], 'aliasingClaims err'
  return claims

wd_.getClaimSubjects = (property, value, refresh)->
  preq.get app.API.data.claim(property, value, refresh)
  .then _.Log("claim subjects - #{property}:#{value}")
  .then _.property('entities')

wd_.queryAuthorWorks = (authorQid, refresh)->
  preq.get app.API.data.authorWorks(authorQid, refresh)
  .then _.Log("author work - #{authorQid}")
  .then _.property('entities')

# P364: original language of work
# P103: native language
langProperties = ['P364', 'P103']

wd_.getOriginalLang = (claims, notSimplified)->
  langClaims = _.pick claims, langProperties
  if _.objLength(langClaims) is 0 then return

  # this has to be simplified claims
  if notSimplified then langClaims = wdk.simplifyClaims langClaims

  originalLangWdId = _.pickOne(langClaims)?[0]
  return window.wdLang.byWdId[originalLangWdId]?.code
