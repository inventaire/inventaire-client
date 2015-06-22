module.exports = wd = sharedLib('wikidata')(_.preq, _)

_.extend wd.API.wmflabs,
  claim: (P, Q)-> app.API.data.wdq 'claim', P, Q

wd.wmCommonsThumb = (file, width=500)->
  width = _.bestImageWidth width
  _.preq.get app.API.data.commonsThumb(file, width)
  .then _.property('thumbnail')
  .catch (err)=>
    console.warn "couldnt find #{file} via tools.wmflabs.org, will use the small thumb version"
    return @wmCommonsSmallThumb file, 200
  .catch _.Error('wmCommonsThumb err')


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

wd.sitelinks = sharedLib 'wiki_sitelinks'
