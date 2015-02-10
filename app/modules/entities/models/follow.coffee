module.exports = Backbone.NestedModel.extend
  url: app.API.entities.followed
  initialize: ->
    if app.user?.loggedIn
      _.preq.get(@url)
      .catch _.preq.catch401
      .then @initializeFollowedEntities.bind(@)
      .always @initializeUpdater.bind(@)
      .catch (err)-> _.error err, 'followed entities err'
    else
      _.log 'user not logged in. not fetching followed entities'

  initializeFollowedEntities: (res)->
    if res?.entities? then @set res.entities

  initializeUpdater: ->
    @on 'change', _.debounce(@updateFollowedList, 500)

  updateFollowedList: (model)->
    [entity, following] = [k, v] for k,v of model.changed
    _.preq.post model.url, {entity: entity, following: following}