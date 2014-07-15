module.exports = class User extends Backbone.Model
  defaults:
    username: null
    email: null
    language: window.navigator.language || 'en'

  # initialize: ->

  # validate: ->