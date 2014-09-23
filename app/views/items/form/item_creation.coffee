module.exports = class ItemCreation extends Backbone.Marionette.ItemView
  template: require 'views/items/form/templates/item_creation'
  className: "addEntity"
  initialize: ->
    @entity = @options.entity
    attrs =
      title: @entity.get 'title'
      entity: @entity.get 'uri'
      claims:
        P31: @entity.get 'uri'

    if pictures = @entity.get 'pictures'
      attrs.pictures = pictures

    attrs.owner = app.user.id

    if attrs.entity? and attrs.title?
      @model = new app.Model.Item attrs
    else throw new Error 'missing uri or title at item creation from entity'

  serializeData: ->
    attrs =
      title: @entity.get 'title'
      listings: app.user.listings
    attrs.header = _.i18n 'add_item_text', {title: attrs.title}
    return attrs

  events:
    'click #validate': 'validateItem'
    'click #cancel': -> app.execute 'show:home'

  validateItem: ->
    comment = $('#comment').val()
    listing = $('#listingPicker').val()
    if listing?
      @model.set 'listing', listing
      @model.set 'comment', comment  if comment?
      itemData = @model.toJSON()
      if app.request 'item:validate:creation', itemData
        app.execute 'show:home'
      else throw new Error "couldn't validateItem"
    else throw new Error 'no value found for the listing'

