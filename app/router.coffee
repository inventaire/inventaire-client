app = app || {}
app.ApplicationRouter = Backbone.Router.extend(
  routes:
    "contacts/search/:pattern": "filterContact"
    "contacts/:id": "showContact"

  showContact: (id) ->
    contact = app.Contacts.get(id)
    app.MainView.showContact contact
    return

  filterContact: (pattern) ->
    app.MainView.contactList.filter pattern
    return
)
