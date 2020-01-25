error_ = require 'lib/error'
listings_ = require 'modules/user/lib/user_listings.coffee'

module.exports = Backbone.Model.extend
  initialize: (attrs)->
    shelfListing = @get('listing')
    listingKeys = listings_(app)[shelfListing]

    @set 'pathname', "/shelves/#{attrs._id}"
    @set 'icon', listingKeys.icon
    @set 'label', listingKeys.label
