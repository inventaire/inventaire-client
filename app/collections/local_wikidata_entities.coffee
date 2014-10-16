WikidataEntities = require 'collections/wikidata_entities'

module.exports = class LocalWikidataEntities extends WikidataEntities
  initialize: -> @fetch()
  localStorage: new Backbone.LocalStorage 'wd:Entities'

  fetchModels: (ids, Model)->
    wdIds = ids.filter(wd.isWikidataEntityId)
    [cached, missing] = @modelsStatus(wdIds)
    _.log cached, 'cached'
    _.log missing, 'missing'
    if _.isEmpty missing
      return $.Deferred().resolve(cached)
    else
      @getMissingEntities(missing, Model)
      .then ()=>
        [cached, missing] = @modelsStatus(wdIds)
        if missing.length > 0
          console.error 'missing models', missing
        return cached

  getMissingEntities: (ids, Model)->
    Model ||= app.Model.WikidataEntity
    wd.getEntities(ids, app.user.lang)
    .then (res)=>
      for k,v of res.entities
        @create new Model(v)
    .fail (err)-> _.log err, 'getMissingEntities err'