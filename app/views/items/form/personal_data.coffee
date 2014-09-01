module.exports = class PersonalData extends Backbone.Marionette.ItemView
  template: require 'views/items/form/templates/personal_data'
  serializeData: ->
    attrs = @model.toJSON()
    _.extend attrs, wd.serializeWikiData(attrs.entity.cachedData)
    _.log attrs, 'attrs'
    attrs.header = _.i18n('add_item_text', {label: attrs.label})
    attrs.listings = app.user.listings
    return attrs

  events:
    'click #validate': 'validateItem'


  validateItem: ->
    # clarifiez les données: pas de model tant que l'on bidouille des données
    # model uniquement pour objet persisté!!!!!
    @model.attributes.entity.label = @model.attributes.entity.cachedData.attrs.label
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

