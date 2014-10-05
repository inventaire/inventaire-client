module.exports = class Entities extends Backbone.Collection
  # model: require 'models/non_wikidata_entity'
  byUri: (uri)-> @findWhere {uri: uri}
  byDomain: (domain)->
    regex = new RegExp("^#{domain}")
    @filter (entity)->
      uri = entity.get('uri')
      if regex.test(uri) then true

  wd: -> @byDomain('wd')
  isbn: -> @byDomain('isbn')

  fetchModels: (ids, Model)->
    wdEntities = ids.filter(wd.isWikidataEntityId)
    [cached, missing] = @modelsStatus(wdEntities)
    _.log cached, 'cached'
    _.log missing, 'missing'
    if _.isEmpty missing
      return $.Deferred().resolve(cached)
    else
      @getWikidataEntities(missing, Model)
      .then ()=>
        [cached, missing] = @modelsStatus(wdEntities)
        if missing.length > 0
          console.error 'missing models', missing
        return cached

  getWikidataEntities: (ids, Model)->
    Model ||= app.Model.WikidataEntity
    wd.getEntities(ids, app.user.lang)
    .then (res)=>
      for k,v of res.entities
        @create new Model(v)
    .fail (err)-> _.log err, 'getWikidataEntities err'
