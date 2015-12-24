Filterable = require 'modules/general/models/filterable'

module.exports = Filterable.extend
  setPathname: ->
    username = @get('username')
    @set 'pathname', "/inventory/#{username}"
  asMatchable: ->
    [
      @get('username')
      @get('bio')
    ]

  hasPosition: -> @has 'position'
  getPosition: ->
    latLng = @get 'position'
    if latLng?
      [ lat, lng ] = latLng
      return { lat: lat, lng: lng }
    else return {}

  getLatLng: ->
    # Create a L.LatLng only once
    # Update it when position update (only required for the main user)
    if @_latLng? then return @_latLng
    else @setLatLng()

  setLatLng: ->
    if @hasPosition()
      [ lat, lng ] = @get 'position'
      return @_latLng = new L.LatLng lat, lng
    else
      return @_latLng = null

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
