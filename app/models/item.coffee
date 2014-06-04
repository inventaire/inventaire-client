idGenerator = require('lib/id_generator')

module.exports = Item = Backbone.Model.extend({
  defaults: {
    id: idGenerator(6)
    title: "no title"
  }

  initialize: ->

  validate: ->

  })