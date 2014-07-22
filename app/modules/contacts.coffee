module.exports = (module, app, Backbone, Marionette, $, _) ->
  initializeContacts(app)
  fetchContactsAndTheirItems(app)
  initializeContactSearch(app)

initializeContacts = (app)->
  app.contacts = new app.Collection.Contacts

  app.reqres.setHandler 'getUsernameFromId', (id)->
    contactModel = app.contacts._byId[id]
    if contactModel? && contactModel.get?
      return contactModel.get 'username'
    else
      _.log 'couldnt find the contact'
      return 'username error'

  # include main user in contacts to be able to access it from getUsernameFromId
  app.contacts.add app.user

  app.commands.setHandler 'contact:follow', (contactModel)->
    followNewContact.call app.user, contactModel.id
    _.log contactModel.get('_id'), '_id'
    contactModel.set('following', true)

  app.commands.setHandler 'contact:unfollow', (contactModel)->
    unfollowContact.call app.user, contactModel.id
    _.log contactModel.get('_id'), '_id'
    contactModel.set('following', false)

  app.commands.setHandler 'contact:fetchItems', (contactModel)-> fetchContactItems.call contactModel
  app.commands.setHandler 'contact:removeItems', (contactModel)-> removeContactItems.call contactModel

fetchContactsAndTheirItems = ->
  $.getJSON '/api/contacts'
  .then (res)->
    res.forEach (contact)->
      contact.following = true
      contactModel = app.contacts.add contact
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
      return model.get('following')
  else
    @removeFilter 'following'
    filterExpr = new RegExp text, "i"
    @filterBy 'text', (model)->
      return model.matches filterExpr

queryContacts = (text)->
  $.getJSON "/api/users?#{text}"
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
        @update()
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
      @set 'contacts', _.without(currentContacts, contactId)
      @update()
      app.commands.execute 'contact:removeItems', app.contacts._byId[contactId]
    else
      _.log contactId, 'not in contacts, how did you got here?'
  else
    _.log contactId, "coudn't find contact id "

fetchContactItems = ->
  _.log username = @get('username'), 'fetch contacts items'
  $.getJSON "/api/#{@id}/items"
  .done (res)->
    res.forEach (item)->
      item.username = username
      app.items.add item

removeContactItems = ->
  return app.items.remove(app.items.where({owner: @id}))