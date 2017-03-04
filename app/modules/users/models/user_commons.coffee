Positionable = require 'modules/general/models/positionable'

module.exports = Positionable.extend
  setPathname: ->
    username = @get('username')
    @set 'pathname', "/inventory/#{username}"

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
    # Make lastAdd default to the user creation date
    data = { itemsCount: 0, lastAdd: @get('created') }

    { itemsCount, lastAdd } = _.values @get('snapshot')
      .reduce aggregateScoreData, data

    # Setting those as model attributes
    # so that updating them trigger a model 'change' event
    @set 'itemsCount', itemsCount
    @set 'itemsLastAdded', lastAdd

  getRss: -> app.API.feeds 'user', @id

aggregateScoreData = (data, snapshotSection)->
  { 'items:count':count, 'items:last-add':lastAdd } = snapshotSection
  data.itemsCount += count
  if lastAdd > data.lastAdd then data.lastAdd = lastAdd
  return data
