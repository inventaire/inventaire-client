listings_ = require 'modules/user/lib/user_listings.coffee'
{ getColorSquareDataUriFromModelId } = require 'lib/images'
{ getById } = require '../lib/shelf'

module.exports = Backbone.Model.extend
  initialize: (attrs)->
    shelfListing = @get('listing')
    listingKeys = listings_(app)[shelfListing]

    @set 'pathname', "/shelf/#{attrs._id}"
    @set 'icon', listingKeys.icon
    @set 'label', listingKeys.label
    @set 'type', 'shelf'
    @set 'hasItemsCount', true
    unless @get('picture')?
      @set 'picture', getColorSquareDataUriFromModelId @get('_id')

    @waitForItemsCount = @setItemsCount()

  serializeData: ->
    attrs = @toJSON()

    _.extend attrs,
      isShelf: true

  setItemsCount: ->
    if @get('newPlaceholder') then return Promise.resolve()
    getById(@get('_id'))
    .then (shelf)=>
      count = shelf.items.length
      @set 'itemsCount', count

  updateMetadata: ->
    name: @get 'name'
    description: @get 'description'
    url: @get 'pathname'
