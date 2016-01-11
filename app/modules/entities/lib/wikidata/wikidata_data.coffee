module.exports = (app, _, wd, promises_)->
  remote =
    # don't specify a language to allow wikidata_entity models to handle language fallbacks
    get: wd.getEntities

  local = new app.LocalCache
    name: 'entities_wd'
    remote: remote
    parseData: _.property 'entities'

  return wdData =
    local: local
    remote: remote