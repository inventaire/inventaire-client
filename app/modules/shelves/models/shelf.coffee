{ getColorSquareDataUriFromModelId } = require 'lib/images'
{ getById } = require '../lib/shelf'

module.exports = Backbone.Model.extend
  initialize: (attrs)->
    shelfListing = @get('listing')
    listingKeys = app.user.listings.data[shelfListing]

    @set
      pathname: "/shelves/#{attrs._id}"
      icon: listingKeys.icon
      label: listingKeys.label
      type: 'shelf'

    unless @get('picture')?
      @set 'picture', getColorSquareDataUriFromModelId @get('_id')

  updateMetadata: ->
    title: @get 'name'
    description: @get 'description'
    image: @get 'picture'
    url: @get 'pathname'
    # TODO: implement shelves RSS feeds server-side
    # rss: @getRss()
