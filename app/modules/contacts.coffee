module.exports = (module, app, Backbone, Marionette, $, _) ->
  initializeContacts(app)
  initializeContactSearch(app)

initializeContacts = (app)->
  app.contacts = new app.Collection.Contacts
  app.contacts.fetch()
  app.contacts.add(app.user)

initializeContactSearch = (app)->
  app.contactsSearchResults = new app.Collection.Contacts
  app.contactsSearchResults.successfullQueries = []
  app.commands.setHandler 'contactSearch', contactSearch

contactSearch = (text)->
  if text != '' && _.indexOf(app.contactsSearchResults.successfullQueries, text) == -1
    console.log "contact search: #{text}"
    $.getJSON "/api/users?#{text}"
    .then (res)->
      res.forEach (contact)->
        app.contactsSearchResults.add contact
      app.contactsSearchResults.successfullQueries.push(text)
  else
    console.log "rejected search: #{text}"
