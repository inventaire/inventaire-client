listings_ = require 'modules/user/lib/user_listings.coffee'
{ getColorSquareDataUriFromModelId } = require 'lib/images'

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
    _.preq.get app.API.shelves.byIds @get('_id')
    .get 'shelves'
    .then (res)=>
      shelf = Object.values(res)[0]
      count = shelf.items.length
      @set 'itemsCount', count

  updateMetadata: ->
    name: @get 'name'
    description: @get 'description'
    url: @get 'pathname'
