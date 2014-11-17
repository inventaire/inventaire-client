module.exports = class ItemEditionForm extends Backbone.Marionette.ItemView
  template: require './templates/item_edition'
  behaviors:
    SuccessCheck: {}

  serializeData: ->
    listings = _.clone(app.user.listings)
    listings[@model.get('listing')].selected = true

    return _.extend @model.toJSON(),
      listings: listings

  events:
    'change select#listingPicker': 'updateListing'

  updateListing: (e)->
    app.request 'item:update',
      item: @model
      attribute: 'listing'
      value: e.target.value
      selector: 'select#listingPicker'
