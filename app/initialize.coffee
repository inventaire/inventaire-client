require('lib/handlebars_partial_helper')()
AppView = require "views/app_view"

#changing the default attribute to fit Couch/PouchDB
Backbone.Model.prototype.idAttribute = '_id'
# Backbone.sync = BackbonePouch.sync
#   db: PouchDB 'mydb'
#   listen: true
#   fetch: 'query'

# Initialize the application on DOM ready event.
$ ->
  # initialize foundation
  $(document).foundation()

  appView = new AppView
  # console.log "/!\\ router desactivated"
  return