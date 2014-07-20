module.exports = (module, app, Backbone, Marionette, $, _) ->
  initializeContacts(app)
  initializeContactSearch(app)

initializeContacts = (app)->
  app.contacts = new app.Collection.Contacts
  $.getJSON '/api/contacts'
  .then (res)->
    res.forEach (contact)->
      contact.following = true
      app.contacts.add contact
  .fail (err)-> console.error(err)
  .done()

  app.commands.setHandler 'contact:follow', (contactId)-> followNewContact.call(app.user, contactId)

initializeContactSearch = (app)->
  app.filteredContacts = new FilteredCollection app.contacts
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
  .then (res)->
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
  currentContacts = @get 'contacts'
  if contactId?
    if contactId != @get('_id')
      _.log currentContacts, 'currentContacts'
      if currentContacts.indexOf(contactId) is -1
        @escape 'contacts', currentContacts.push(contactId)
        @update()
      else
        _.log "this contact is already added"
    else
      _.log "you can't add yourself"
  else
    _.log contactId, "coudn't find contact id "