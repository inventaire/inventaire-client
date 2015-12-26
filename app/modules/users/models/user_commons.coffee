Positionable = require 'modules/general/models/positionable'

module.exports = Positionable.extend
  setPathname: ->
    username = @get('username')
    @set 'pathname', "/inventory/#{username}"
  asMatchable: ->
    [
      @get('username')
      @get('bio')
    ]

  updateMetadata: ->
    app.execute 'metadata:update',
      title: @get 'username'
      description: @getDescription()
      image: @get 'picture'
      url: @get 'pathname'

  getDescription: ->
    bio = @get('bio')
    if _.isNonEmptyString bio then return bio
    else _.i18n 'user_default_description', {username: @get('username')}
