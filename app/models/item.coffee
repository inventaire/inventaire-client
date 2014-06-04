idGenerator = require 'lib/id_generator'

module.exports = Item = Backbone.Model.extend
  defaults:
    title: "no title"

  initialize: ->

  validate: ->