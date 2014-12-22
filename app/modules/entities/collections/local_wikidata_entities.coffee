WikidataEntities = require './wikidata_entities'
WikidataEntity = require '../models/wikidata_entity'
AuthorWikidataEntity = require '../models/author_wikidata_entity'
wd = app.lib.wikidata

module.exports = class LocalWikidataEntities extends WikidataEntities
  localStorage: new Backbone.LocalStorage 'wd:Entities'

  fetchModels: (ids, type)->
    wdIds = ids.filter(wd.isWikidataEntityId)
    [inMemory, missing] = @modelsStatus(wdIds)
    _.log inMemory, 'inMemory'
    _.log missing, 'missing'
    if _.isEmpty missing
      return $.Deferred().resolve(inMemory)
    else
      @getMissingEntities(missing, type)
      .then ()=>
        [inMemory, missing] = @modelsStatus(wdIds)
        if missing.length > 0
          console.error 'missing models', missing
        return inMemory

  getMissingEntities: (ids, type)->
    switch type
      when 'author' then Model = AuthorWikidataEntity
      else
        console.warn "unknown entity type: #{type}"
        Model = WikidataEntity

    _.log Model, 'MODEL !!!!!!!!!!!!!!!!!!!!!!!!!!!'
    # over-passing the module method to fetch many entities at once
    # should be re-integrated to the entity module
    wd.getEntities(ids, app.user.lang)
    .then (res)=>
      for k,v of res.entities
        @create new Model(v)
    .fail (err)-> _.logXhrErr err, 'getMissingEntities err'

  recoverDataById: (id)->
    _.log "entity:recoverDataById #{id}"
    @localStorage.find({id:id})

  modelsStatus: (ids)->
    # outputs the model objet or the id string
    models = ids.map (id)=> @byId(id) or id

    inMemory = models.filter (model)-> _.isObject model
    notInMemory = models.filter (model)-> _.isString model

    missing = []
    notInMemory.forEach (id)=>
      data = @recoverDataById(id)
      if data?
        model = @add data
        inMemory.push(model)
      else missing.push(id)

    return [inMemory, missing]