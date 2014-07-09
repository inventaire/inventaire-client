require('lib/handlebars_partial_helper')()
app = require 'app'

# #changing the default attribute to fit CouchDB
Backbone.Model.prototype.idAttribute = '_id'


# Initialize the application on DOM ready event.
$ ->
  app.initialize()
  window.app = app