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
    unless @get('picture')?
      @set 'picture', getColorSquareDataUriFromModelId @get('_id')

  updateMetadata: ->
    name: @get 'name'
    description: @get 'description'
    url: @get 'pathname'
    icon: @get 'icons'
    label: @get 'label'
