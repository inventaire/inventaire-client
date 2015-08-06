aliases = sharedLib 'wikidata_aliases'

module.exports = wd = sharedLib('wikidata')(_.preq, _, wdk)

# more complete data access: can include author and license
wd.wmCommonsThumbData = (file, width=500)->
  width = _.bestImageWidth width
  _.preq.get app.API.data.commonsThumb(file, width)

wd.wmCommonsThumb = (file, width=500)->
  wd.wmCommonsThumbData file, width
  .then _.property('thumbnail')
  .catch (err)=>
    console.warn "couldnt find #{file} via tools.wmflabs.org, will use the small thumb version"
    return @wmCommonsSmallThumb file, 200


wd.wikipediaExtract = (lang, title)->
  _.preq.get app.API.data.wikipediaExtract(lang, title)
  .then (data)->
    { extract, url } = data
    return sourcedExtract extract, url
  .catch _.Error('wikipediaExtract err')

# add a link to the full wikipedia article at the end of the extract
sourcedExtract = (extract, url)->
  if url?
    text = _.i18n 'read_more_on_wikipedia'
    return extract += "<br><a href='#{url}' class='source link' target='_blank'>#{text}</a>"
  else extract

# wd.normalizeTime = wdk.normalizeWikidataTime
wd.sitelinks = sharedLib 'wiki_sitelinks'

wd.aliasingClaims = (claims)->
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
