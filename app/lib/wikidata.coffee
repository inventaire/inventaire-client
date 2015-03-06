wd = sharedLib('wikidata')(_.preq, _)

_.extend wd.API.wmflabs,
  claim: (P, Q)-> app.API.data 'wdq', 'claim', P, Q

wd.sitelinks = sharedLib 'wiki_sitelinks'
module.exports = wd