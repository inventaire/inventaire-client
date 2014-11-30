module.exports = class ItemLi extends Backbone.Marionette.ItemView
  tagName: 'figure'
  className: 'itemContainer white-shadow-box'
  template: require './templates/item_figure'
  behaviors:
    ConfirmationModal: {}

  initialize: ->
    @listenTo @model, 'change', @render

  onShow: -> app.execute('foundation:reload')

  events:
    'click .edit': 'itemEdit'
    'click a.itemShow, img:not(.profilePic)': 'itemShow'
    'click a.user': -> app.execute 'show:user', @username
    'click .remove': 'itemDestroy'
    'click a.commentToggleWrap': -> @toggleWrap('comment')
    'click a.notesToggleWrap': -> @toggleWrap('notes')
    'click a.transaction': 'updateTransaction'
    'click a.listing': 'updateListing'

  serializeData: ->
    attrs = @model.serializeData()
    attrs.wrap =
      comment:
        wrap: attrs.comment?.length > 120
        nameBase: 'comment'
      notes:
        wrap: attrs.notes?.length > 120
        nameBase: 'notes'
    attrs.currentTransaction = Items.transactions[attrs.transaction]
    @username = attrs.username
    attrs.username = _.style @username, 'strong'
    unless attrs.restricted
      attrs.transactions = Items.transactions
      attrs.currentListing = app.user.listings[attrs.listing]
      attrs.listings = app.user.listings
      attrs.uiId = _.idGenerator(4, true)
    return attrs

  updateTransaction: (e)->
    @updateItem 'transaction', e.target.id
  updateListing: (e)->
    @updateItem 'listing', e.target.id
  updateItem: (attribute, value)->
    app.request 'item:update',
      item: @model
      attribute: attribute
      value: value

  itemEdit: -> app.execute 'show:item:form:edition', @model

  itemShow: -> app.execute 'show:item:show:from:model', @model

  itemDestroy: ->
    app.request 'item:destroy',
      model: @model
      selector: @el

  toggleWrap: (nameBase)->
    @$el.find("span.#{nameBase}").toggleClass('wrapped')
    @$el.find("a.#{nameBase}ToggleWrap").find('.fa').toggle()