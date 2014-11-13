module.exports =
  define: (module, app, Backbone, Marionette, $, _) ->

  initialize: ->
    app.users = require('./users_collections')(app)
    initDataHandlers()
    initUsersReqRes()
    app.request 'waitForUserData', fetchFriendsAndTheirItems
    initializeUserSearch()

initDataHandlers = ->
  remoteData =
    get: (ids)-> _.preq.get app.API.users.data(ids)
    search: (text)-> _.preq.get app.API.users.search(text)

  app.users.data =
    remote: remoteData
    local: new app.LocalCache
      name: 'users'
      remoteDataGetter: remoteData.get
      parseData: (data)-> data.users

initUsersReqRes = ->
  app.reqres.setHandlers
    'getUsernameFromUserId': (id)->
      userModel = app.users.byId(id)
      if userModel? then userModel.get('username')
      else console.warn "couldnt find the user from id: #{id}"

    'getUserIdFromUsername': (username)->
      userModel = app.users.findWhere({username: username})
      if userModel? then userModel.id
      else console.warn "couldnt find the user from username: #{username}"

    'getProfilePicFromId': (id)->
      userModel = app.users.byId(id)
      if userModel? then userModel.get 'picture'
      else console.warn "couldnt find the user from id: #{id}"

  app.commands.setHandlers
  #   'contact:follow': (userModel)->
  #     followNewContact.call app.user, userModel.id
  #     userModel.following = true
  #     userModel.trigger 'change:following', userModel

  #   'contact:unfollow': (userModel)->
  #     unfollowContact.call app.user, userModel.id
  #     userModel.following = false
  #     userModel.trigger 'change:following', userModel

    'contact:fetchItems': (userModel)-> fetchContactItems.call userModel
    # 'contact:removeItems': (userModel)-> removeContactItems.call userModel

fetchFriendsAndTheirItems = ->
  fetchRelationsData()
  .then (relationsData)->

    # FRIENDS
    relationsData.friends.forEach (friend)->
      userModel = app.users.friends.add friend
      userModel.following = true
      # trigger 'change:following' to update ui (ex: user_li)
      userModel.trigger 'change:following', userModel
      app.execute 'contact:fetchItems', userModel
    app.users.fetched = true
    app.vent.trigger 'users:ready'

    # REQUESTED: todo with the friend request menu

  .catch (err)->
    _.log err, 'get err'
    throw new Error('get', err.stack or err)

fetchRelationsData = ->
  relations = app.user.get('relations')
  _.log relations, 'relations'
  ids = _.flatten _.values(relations)
  _.log ids, 'fetchRelationsData ids'
  return app.users.data.local.get(ids)
  .then (data)-> spreadRelationsData(data, relations)

spreadRelationsData = (data, relations)->
  relationsData =
    friends: []
    userRequests: []
    othersRequests: []

  for relationType, list of relations
    list.forEach (user)->
      relationsData[relationType].push data[user]
  return relationsData

initializeUserSearch = ->
  app.users.friends.filtered = new FilteredCollection(app.users.friends)
  app.users.queried = []
  app.commands.setHandler 'userSearch', userSearch

userSearch = (text)->
  filterUsers.call(app.users.friends.filtered, text)
  unless text is '' or _.hasValue(app.users.queried, text)
    console.log "contact search: #{text}"
    queryUsers(text)
  else
    console.log "already queried: #{text}"

filterUsers = (text)->
  if text is ''
    @removeFilter 'text'
    @filterBy 'following', (model)-> model.following
  else
    @removeFilter 'following'
    filterExpr = new RegExp text, "i"
    @filterBy 'text', (model)-> model.matches filterExpr

queryUsers = (text)->
  app.users.data.remote.search(text)
  .done (res)->
    res.forEach (contact)->
      app.users.public.add contact if isntAlreadyHere(contact._id)
    app.users.queried.push(text)

isntAlreadyHere = (id)->
  if app.users.byId(id)?
    _.log id, 'rejected contact: already there'
    return false
  else return true

followNewContact = (contactId)->
  if contactId?
    if contactId != @get('_id')
      currentContacts = @get 'contacts'
      unless _.hasValue(currentContacts, contactId)
        @escape 'contacts', currentContacts.push(contactId)
        @save()
        .then (res)-> _.log res, 'user successfully saved to the server!'
        .fail (err)-> _.log err, 'server error:'
        app.execute 'contact:fetchItems', app.users._byId[contactId]
      else
        _.log "this contact is already added"
    else
      _.log "you can't add yourself"
  else
    _.log contactId, "coudn't find contact id "

unfollowContact = (contactId)->
  if contactId?
    currentContacts = @get 'contacts'
    unless _.hasValue(currentContacts, contactId)
      # for some reason, don't user escape hereafter, it doesn't do the job oO
      @set 'contacts', _.without(currentContacts, contactId)
      @save()
      .then (res)-> _.log res, 'user successfully saved to the server!'
      .fail (err)-> _.log err, 'server error:'
      app.execute 'contact:removeItems', app.users._byId[contactId]
    else
      _.log contactId, 'not in contacts, how did you get here?'
  else
    _.log contactId, "coudn't find contact id "

fetchContactItems = ->
  username = @get('username')
  _.preq.get app.API.users.items(@id)
  .then (res)->
    res.forEach (item)->
      itemModel = Items.friends.add item
      itemModel.username = username

removeContactItems = ->
  return Items.friends.remove(Items.friends.where({owner: @id}))