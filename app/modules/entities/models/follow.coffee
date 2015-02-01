module.exports = Backbone.NestedModel.extend
  url: app.API.entities.followed
  initialize: ->
    _.preq.get(@url)
    .then @initializeFollowedEntities.bind(@)
    .always @initializeUpdater.bind(@)

  initializeFollowedEntities: (res)-> @set res.entities

  initializeUpdater: ->
    @on 'change', _.debounce(@updateFollowedList, 500)

  updateFollowedList: (model)->
    [entity, following] = [k, v] for k,v of model.changed
    _.preq.post model.url, {entity: entity, following: following}