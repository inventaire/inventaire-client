module.exports = class ItemEditionForm extends Backbone.Marionette.ItemView
  template: require 'views/items/form/templates/item_edition'
  behaviors:
    SuccessCheck: {}

  serializeData: ->
    attrs = @model.toJSON()
    attrs.listings = app.user.listings
    return attrs

  events:
    'change select#listingPicker': 'updateListing'

  updateListing: (e)->
    app.request 'item:update',
      item: @model
      attribute: 'listing'
      value: e.target.value
      selector: 'select#listingPicker'
