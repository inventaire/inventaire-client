Contact = require "../models/contact"

module.exports = Backbone.Collection.extend(
  model: Contact
  localStorage: new Backbone.LocalStorage("contact-book")
  comparator: (model) ->
    model.get "firstName"

  filtered: (expr) ->
    return @filter (contact) ->
      true  if contact.matches(expr)

)