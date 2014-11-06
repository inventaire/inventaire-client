module.exports =
  define: (module, app, Backbone, Marionette, $, _) ->

  initialize: ->
    initializeContacts()
    app.request 'waitForUserData', fetchContactsAndTheirItems
    initializeContactSearch()

initializeContacts = ->
  app.contacts = new app.Collection.Contacts

  remoteData =
    get: (ids)-> $.getJSON app.API.users.data(ids)

  app.contacts.data =
    remote: remoteData
    local: new app.LocalCache
      localDb: Level('users')
      remoteDataGetter: remoteData.get
      parseData: (data)-> data.users

  app.reqres.setHandlers
    'getUsernameFromOwner': (id)->
      contactModel = app.contacts.byId(id)
      if contactModel? then contactModel.get('username')
      else
        console.warn "couldnt find the contact from id: #{id}"
        return

    'getOwnerFromUsername': (username)->
      contactModel = app.contacts.findWhere({username: username})
      if contactModel? then contactModel.id
      else
        console.warn "couldnt find the contact from username: #{username}"
        return

    'getProfilePicFromId': (id)->
      contactModel = app.contacts.byId(id)
      if contactModel? then contactModel.get 'picture'
      else
        console.warn "couldnt find the contact from id: #{id}"
        return

  # include main user in contacts to be able to access it from getUsernameFromOwner
  app.contacts.add app.user

  app.commands.setHandlers
    'contact:follow': (contactModel)->
      followNewContact.call app.user, contactModel.id
      contactModel.following = true
      contactModel.trigger 'change:following', contactModel

    'contact:unfollow': (contactModel)->
      unfollowContact.call app.user, contactModel.id
      contactModel.following = false
      contactModel.trigger 'change:following', contactModel

    'contact:fetchItems': (contactModel)-> fetchContactItems.call contactModel
    'contact:removeItems': (contactModel)-> removeContactItems.call contactModel

fetchContactsAndTheirItems = ->
  fetchRelationsData()
  .then (relationsData)->

    # FRIENDS
    relationsData.friends.forEach (friend)->
      contactModel = app.contacts.add friend
      contactModel.following = true
      contactModel.trigger 'change:following', contactModel
      app.execute 'contact:fetchItems', contactModel
    app.contacts.fetched = true
    app.vent.trigger 'contacts:ready'

    # REQUESTED: todo with the friend request menu

  .catch (err)->
    _.log err, 'get err'
    throw new Error('get', err.stack or err)

fetchRelationsData = ->
  relations = app.user.get('relations')
  _.log relations, 'relations'
  ids = _.flatten _.values(relations)
  _.log ids, 'fetchRelationsData ids'
  return app.contacts.data.local.get(ids)
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

initializeContactSearch = ->
  app.filteredContacts = new FilteredCollection app.contacts
  app.filteredContacts.filterBy 'not-main-user', (model)-> return model.get('_id') != app.user.id
  app.contacts.queried = []
  app.commands.setHandler 'contactSearch', contactSearch

contactSearch = (text)->
  filterContacts.call(app.filteredContacts, text)
  if text isnt '' and app.contacts.queried.indexOf(text) is -1
    console.log "contact search: #{text}"
    queryContacts(text)
  else
    console.log "already queried: #{text}"

filterContacts = (text)->
  if text is ''
    @removeFilter 'text'
    @filterBy 'following', (model)->
      return model.following
  else
    @removeFilter 'following'
    filterExpr = new RegExp text, "i"
    @filterBy 'text', (model)->
      return model.matches filterExpr

queryContacts = (text)->
  $.getJSON app.API.contacts.search(text)
  .done (res)->
    res.forEach (contact)->
      app.contacts.add contact if isRelevant.call contact
    app.contacts.queried.push(text)

isRelevant = ()->
  return false if @_id is app.user.id
  if app.contacts.findWhere {_id:@_id}
    _.log @_id, 'rejected contact: already there'
    return false
  _.log @_id, 'valid contact'
  return true

followNewContact = (contactId)->
  if contactId?
    if contactId != @get('_id')
      currentContacts = @get 'contacts'
      if currentContacts.indexOf(contactId) is -1
        @escape 'contacts', currentContacts.push(contactId)
        @save()
        .then (res)-> _.log res, 'user successfully saved to the server!'
        .fail (err)-> _.log err, 'server error:'
        app.execute 'contact:fetchItems', app.contacts._byId[contactId]
      else
        _.log "this contact is already added"
    else
      _.log "you can't add yourself"
  else
    _.log contactId, "coudn't find contact id "

unfollowContact = (contactId)->
  if contactId?
    currentContacts = @get 'contacts'
    if currentContacts.indexOf(contactId) isnt -1
      # for some reason, don't user escape hereafter, it doesn't do the job oO
      @set 'contacts', _.without(currentContacts, contactId)
      @save()
      .then (res)-> _.log res, 'user successfully saved to the server!'
      .fail (err)-> _.log err, 'server error:'
      app.execute 'contact:removeItems', app.contacts._byId[contactId]
    else
      _.log contactId, 'not in contacts, how did you get here?'
  else
    _.log contactId, "coudn't find contact id "

fetchContactItems = ->
  username = @get('username')
  console.log('fetchContactItems arguments', arguments)
  console.log('fetchContactItems this', this)
  $.getJSON app.API.contacts.items(@id)
  .done (res)->
    res.forEach (item)->
      itemModel = Items.contacts.add item
      itemModel.username = username

removeContactItems = ->
  return Items.contacts.remove(Items.contacts.where({owner: @id}))