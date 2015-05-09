wd = sharedLib('wikidata')(_.preq, _)

_.extend wd.API.wmflabs,
  claim: (P, Q)-> app.API.data.wdq 'claim', P, Q

wd.wmCommonsThumb = (file, width=500)->
  _.preq.get app.API.data.commonsThumb(file, width)
  .then _.property('thumbnail')
  .catch (err)=>
    console.warn "couldnt find #{file} via tools.wmflabs.org, will use the small thumb version"
    return @wmCommonsSmallThumb file, 200
  .catch _.Error('wmCommonsThumb err')


wd.sitelinks = sharedLib 'wiki_sitelinks'
module.exports = wd