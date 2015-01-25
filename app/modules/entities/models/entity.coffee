module.exports = class Entity extends Backbone.NestedModel
  initLazySave: -> @save = _.debounce lazySave.bind(@), 100

  lazySave = ->
    app.request 'save:entity:model', @prefix, @toJSON()