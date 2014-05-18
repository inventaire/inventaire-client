ContactBook = require "collections/contacts"
AppView = require "views/app_view"
# Application = require 'application'
# routes = require 'routes'

# # Initialize the application on DOM ready event.
$ ->
  # $(document).foundation()
#   new Application {
#     title: 'Brunch example application',
#     controllerSuffix: '-controller',
#     routes
#   }
  console.log "INIT!!"
  Contacts = new ContactBook()
  App = new AppView(Contacts)

  # collection = new ContactBook()
  # collection.create firstName: "John"
  # collection.create firstName: "Jane"
  # _.each collection.filtered(/ja/i), (contact) ->
  #   console.log "hello " + contact.get("firstName")
  # tmpl = document.getElementById('comment-template');
  # document.body.appendChild(tmpl.content.cloneNode(true));