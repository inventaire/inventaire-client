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
    _.log update, 'update'
    for entity, bool of update
      if bool then @addEntity(entity)
      else @remove(entity)

  addEntity: (entity)->
    app.request('get:entity:model', entity)
    .then @add.bind(@)
