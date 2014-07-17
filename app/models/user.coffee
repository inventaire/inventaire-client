module.exports = class User extends Backbone.Model
  # defaults:
  #   username: null
  #   email: null
  #   language: window.navigator.language || 'en'

  url: -> 'user'

  update: =>
    @sync('update', @)

  # sync: ->
    # Backbone.sync.apply(@, ['update', @])

  # initialize: ->

  # validate: ->