ContactListView = require "./contact_list_view"
ContactView = require "./contact_view"
console.log "hello AppView"

module.exports = AppView = Backbone.View.extend(
  el: "#contact-book"
  events:
    "click #new-contact": "newContact"
    "keyup #filter-contacts": "filterContacts"

  initialize: (collection) ->
    @collection = collection
    @contactList = new ContactListView(collection)
    @listenTo @contactList, "select", @selectContact
    return

  newContact: ->
    @collection.create firstName: "Unnamed"
    @selectContact @collection.last()
    return

  selectContact: (contact) ->
    @currentContact = contact
    @showContact contact
    return

  showContact: (contact) ->
    view = new ContactView(model: contact)
    @$("#contact-details").html view.render().el
    input = view.$(".contact-firstName").get(0)
    input.focus()
    input.select()
    return

  filterContacts: (ev) ->
    $elem = $(ev.currentTarget)
    @contactList.filter $elem.val()
    return
)
