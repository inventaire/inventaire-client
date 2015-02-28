module.exports = Backbone.Collection.extend
  initialize: (models, options)->
    {list} = options
    if list.length > 0
      @updateCollection list.toJSON()
    @listenTo list, 'change', @listUpdated.bind(@)

  listUpdated: (list)->
    _.log list, 'listUpdated list'
    @updateCollection list.changed

  updateCollection: (update)->
    for entity, bool of update
      if bool then @addEntity(entity)
      else @remove(entity)

  addEntity: (entity)->
    app.request('get:entity:model', entity)
    .then setUriAsId
    .then @add.bind(@)

# the followed entities list uses entities uris
# so the models needs to use it too
# to stay in sync easily
# (e.g being removed just by passing id)
setUriAsId = (entityModel)->
  uri = entityModel.get('uri')
  entityModel.set('id', uri)
  return entityModel
