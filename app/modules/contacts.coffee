module.exports = (module, app, Backbone, Marionette, $, _) ->
  initializeContacts(app)
  initializeContactSearch(app)

initializeContacts = (app)->
  app.contacts = new app.Collection.Contacts
  $.getJSON '/api/contacts'
  .then (res)->
    res.forEach (contact)-> app.contacts.add contact
  .fail (err)-> console.error(err)
  .done()

  app.commands.setHandler 'contact:new', newContact

initializeContactSearch = (app)->
  search = app.contacts.search = {}
  search.results = new app.Collection.Contacts
  search.queried = []
  search.filtered = new FilteredCollection search.results
  app.commands.setHandler 'contactSearch', contactSearch

contactSearch = (text)->
  filterContacts(text)
  if text isnt '' and app.contacts.search.queried.indexOf(text) is -1
    console.log "contact search: #{text}"
    queryContacts(text)
  else
    console.log "already queried: #{text}"

filterContacts = (text)->
  filterExpr = new RegExp text, "i"
  app.contacts.search.filtered.filterBy 'text', (model)->
    return model.matches filterExpr

queryContacts = (text)->
  $.getJSON "/api/users?#{text}"
  .then (res)->
    res.forEach (contact)->
      app.contacts.search.results.add contact
    app.contacts.search.queried.push(text)

newContact = (contactId)->
  currentContacts = app.user.get 'contacts'
  if contactId?
    if contactId != app.user.get('_id')
      console.log 'currentContacts'
      console.log currentContacts
      if currentContacts.indexOf(contactId) is -1
        app.user.escape 'contacts', currentContacts.push(contactId)
        app.user.update()
      else
        console.log "this contact is already added"
    else
      console.log "you can't add yourself"
  else
    console.log "coudn't find contact id "
    console.log contactId