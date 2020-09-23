{ getColorSquareDataUriFromModelId } = require 'lib/images'
{ getById } = require '../lib/shelves'
error_ = require 'lib/error'

module.exports = Backbone.Model.extend
  initialize: (attrs)->
    { name } = attrs

    unless name? then throw error_.new 'invalid shelf', 500, attrs

    @set
      pathname: "/shelves/#{attrs._id}"
      type: 'shelf'

    unless @get('picture')?
      @set 'picture', getColorSquareDataUriFromModelId @get('_id')

    # The listing is only known for the main user's shelves
    shelfListing = @get('listing')
    if shelfListing?
      listingKeys = app.user.listings.data[shelfListing]
      @set
        icon: listingKeys.icon
        label: listingKeys.label

  updateMetadata: ->
    title: @get 'name'
    description: @get 'description'
    image: @get 'picture'
    url: @get 'pathname'
    # TODO: implement shelves RSS feeds server-side
    # rss: @getRss()
