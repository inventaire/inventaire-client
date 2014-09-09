module.exports = class ItemCreation extends Backbone.Marionette.ItemView
  template: require 'views/items/form/templates/item_creation'
  initialize: ->
    @entity = @options.entity
    attrs =
      entity: @entity.get('uri')
      claims:
        P31: @entity.get('uri')
      title: @entity.get('label')

    if attrs.entity? and attrs.title?
      @model = new app.Model.Item attrs
    else throw new Error 'missing uri or title at item creation from entity'

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
      else throw new Error "couldn't validateItem"
    else throw new Error 'no value found for the listing'

