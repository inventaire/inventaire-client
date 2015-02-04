module.exports = Backbone.NestedModel.extend
  url: app.API.entities.followed
  initialize: ->
    _.preq.get(@url)
    # I can't find how to just catch 401 errors at _.logXhrErr
    # instead of having it poping around here
    # If I remove the catch, it appears as an unhandled error
    .catch (err)-> console.log "follow err #{err.status} (muted)"
    .then @initializeFollowedEntities.bind(@)
    .always @initializeUpdater.bind(@)

  initializeFollowedEntities: (res)-> @set res.entities

  initializeUpdater: ->
    @on 'change', _.debounce(@updateFollowedList, 500)

  updateFollowedList: (model)->
    [entity, following] = [k, v] for k,v of model.changed
    _.preq.post model.url, {entity: entity, following: following}