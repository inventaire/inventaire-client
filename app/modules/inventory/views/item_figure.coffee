module.exports = ItemLi = Backbone.Marionette.ItemView.extend
  tagName: 'figure'
  className: ->
    @uniqueSelector = ".#{@cid}"
    "itemContainer white-shadow-box #{@cid}"
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
    'click a.remove': 'itemDestroy'
    'click a.commentToggleWrap': -> @toggleWrap('comment')
    'click a.notesToggleWrap': -> @toggleWrap('notes')
    'click a.transaction': 'updateTransaction'
    'click a.listing': 'updateListing'

  serializeData: ->
    attrs = @model.serializeData()
    attrs.wrap = @wrapData(attrs)
    attrs.date = {date: attrs.created}
    @username = attrs.username
    return attrs

  wrapData: (attrs)->
    comment:
      wrap: attrs.comment?.length > 120
      nameBase: 'comment'
    notes:
      wrap: attrs.notes?.length > 120
      nameBase: 'notes'

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
      selector: @uniqueSelector
      next: -> console.log 'item deleted'

  toggleWrap: (nameBase)->
    @$el.find("span.#{nameBase}").toggleClass('wrapped')
    @$el.find("a.#{nameBase}ToggleWrap").find('.fa').toggle()