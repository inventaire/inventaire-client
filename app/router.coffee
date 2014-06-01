module.exports = Backbone.Router.extend(
  routes:
    "test": "tester"
  #   "contacts/search/:pattern": "filterContact"
  #   "contacts/:id": "showContact"

  tester: ->
    console.log("hello test, do you hear me?")

  # showContact: (id) ->
  #   contact = app.Contacts.get(id)
  #   app.MainView.showContact contact
  #   return

  # filterContact: (pattern) ->
  #   app.MainView.contactList.filter pattern
  #   return
)
