module.exports = class ItemCreation extends Backbone.Marionette.ItemView
  template: require './templates/item_creation'
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

  onShow: -> app.execute 'foundation:reload'

  serializeData: ->
    attrs =
      entity: @entity.toJSON()
      title: @entity.get 'title'
      listings: app.user.listings
    attrs.header = _.i18n 'add_item_text', {title: attrs.title}
    return attrs

  events:
    'click .select-button-group > .button': 'updateSelector'
    'click #validate': 'validateItem'
    'click #cancel': -> app.execute 'show:home'
    # 'selected:selling': -

  updateSelector: (e)->
    $el = $(e.currentTarget)
    value = $el.attr('id')
    category = $el.parent().attr('id')
    console.log value, category
    @$el.trigger "change:#{value}"
    @$el.trigger "selected:#{value}"
    $el.siblings().removeClass('active')
    $el.addClass('active')

  validateItem: ->
    transaction = $('#transaction').find('.active').first().attr('id')
    comment = $('#comment').val()
    notes = $('#notes').val()
    listing = $('#listing').find('.active').first().attr('id')
    if listing?
      @model.set 'listing', listing
      @model.set 'comment', comment  if comment?
      itemData = @model.toJSON()
      if app.request 'item:validate:creation', itemData
        app.execute 'show:home'
      else throw new Error "couldn't validateItem"
    else throw new Error 'no value found for the listing'

