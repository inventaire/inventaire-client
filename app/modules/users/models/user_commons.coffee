Positionable = require 'modules/general/models/positionable'
error_ = require 'lib/error'
{ getColorSquareDataUriFromModelId } = require 'lib/images'

module.exports = Positionable.extend
  setPathname: ->
    username = @get 'username'
    @set
      pathname: "/inventory/#{username}"
      # Set for compatibility with interfaces expecting a label
      # such as modules/inventory/views/browser_selector
      label: username

  matchable: ->
    [
      @get('username')
      @get('bio')
    ]

  updateMetadata: ->
    title: @get 'username'
    description: @getDescription()
    image: @get 'picture'
    url: @get 'pathname'
    rss: @getRss()

  getDescription: ->
    bio = @get('bio')
    if _.isNonEmptyString bio then return bio
    else _.i18n 'user_default_description', { username: @get('username') }

  setInventoryStats: ->
    created = @get('created') or 0
    # Make lastAdd default to the user creation date
    data = { itemsCount: 0, lastAdd: created }

    snapshot = @get 'snapshot'
    # Known case of missing snapshot data: user documents return from search
    if snapshot?
      data = _.values(snapshot).reduce aggregateScoreData, data

    { itemsCount, lastAdd } = data

    # Setting those as model attributes
    # so that updating them trigger a model 'change' event
    @set 'itemsCount', itemsCount
    @set 'itemsLastAdded', lastAdd

  getRss: -> app.API.feeds 'user', @id

  checkSpecialStatus: ->
    if @get 'special'
      throw error_.new "this layout isn't available for special users", 400, { user: @ }

  setDefaultPicture: ->
    if @get('picture')? then return
    id = @get('_id')
    @set 'picture', getColorSquareDataUriFromModelId(id)

aggregateScoreData = (data, snapshotSection)->
  { 'items:count':count, 'items:last-add':lastAdd } = snapshotSection
  data.itemsCount += count
  if lastAdd > data.lastAdd then data.lastAdd = lastAdd
  return data
