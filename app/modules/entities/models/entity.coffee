module.exports = Entity = Backbone.NestedModel.extend
  initLazySave: -> @save = _.debounce lazySave.bind(@), 100

  lazySave = ->
    app.request 'save:entity:model', @prefix, @toJSON()