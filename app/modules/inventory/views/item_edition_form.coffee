module.exports = ItemEditionForm = Backbone.Marionette.ItemView.extend
  template: require './form/templates/item_edition'
  behaviors:
    SuccessCheck: {}

  initialize: ->
    id = @model.id
    listing = @model.get('listing')
    # in case the item was found in the context of a public item
    # it will miss private data: here we replace the model
    # by its full version
    unless listing?
      fullModel = Items.personal.byId id
      if fullModel? then @model = Items.personal.byId id

  serializeData: ->
    listings = _.clone(app.user.listings)
    listing = @model.get('listing')
    listings[listing].selected = true

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
