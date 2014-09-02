module.exports = class ItemCreation extends Backbone.Marionette.ItemView
  template: require 'views/items/form/templates/item_creation'
  initialize: ->
    @entity = @options.entity  if @options.entity?
    @model = new app.Model.Item {entity: @entity.toJSON()}

  serializeData: ->
    attrs =
      label: @entity.get 'label'
      listings: app.user.listings
    attrs.header = _.i18n('add_item_text', {label: attrs.label})
    return attrs

  events:
    'click #validate': 'validateItem'

  validateItem: ->
    listing = $('#listingPicker').val()
    if listing?
      @model.set('listing', listing)
      itemData = @model.toJSON()
      if app.request('item:validateCreation', itemData)
        app.execute 'show:home'
      else
        console.error "couldn't validateItem"
    else
      console.error 'no value found for the listing'

