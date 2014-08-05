module.exports = (module, app, Backbone, Marionette, $, _) ->
  initializeContacts(app)
  fetchContactsAndTheirItems(app)
  initializeContactSearch(app)

initializeContacts = (app)->
  app.contacts = new app.Collection.Contacts

  app.reqres.setHandlers
    'getUsernameFromId': (id)->
      contactModel = app.contacts._byId[id]
      if contactModel? && contactModel.get?
        return contactModel.get 'username'
      else
        _.log 'couldnt find the contact from id'

    'getIdFromUsername': (username)->
      contactModel = app.contacts.findWhere({username: username})
      if contactModel? && contactModel.get?
        return contactModel.id
      else
        _.log 'couldnt find the contact from username'

    'getProfilePicFromId': (id)->
      contactModel = app.contacts._byId[id]
      if contactModel? && contactModel.get?
        return contactModel.get 'picture'
      else
        _.log 'couldnt find the contact from id'

  # include main user in contacts to be able to access it from getUsernameFromId
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
  $.getJSON '/api/contacts'
  .then (res)->
    res.forEach (contact)->
      contactModel = app.contacts.add contact
      contactModel.following = true
      app.commands.execute 'contact:fetchItems', contactModel
  .fail (err)-> console.error(err)
  .done()

initializeContactSearch = (app)->
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
        app.commands.execute 'contact:fetchItems', app.contacts._byId[contactId]
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
      app.commands.execute 'contact:removeItems', app.contacts._byId[contactId]
    else
      _.log contactId, 'not in contacts, how did you get here?'
  else
    _.log contactId, "coudn't find contact id "

fetchContactItems = ->
  _.log username = @get('username'), 'fetch contacts items'
  $.getJSON app.API.contacts.items(@id)
  .done (res)->
    res.forEach (item)->
      itemModel = app.items.add item
      itemModel.username = username

removeContactItems = ->
  return app.items.remove(app.items.where({owner: @id}))