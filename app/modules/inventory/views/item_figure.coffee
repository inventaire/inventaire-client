module.exports = class ItemLi extends Backbone.Marionette.ItemView
  tagName: 'figure'
  className: 'itemContainer shadowBox'
  template: require './templates/item_figure'
  behaviors:
    ConfirmationModal: {}

  initialize: ->
    @listenTo @model, 'change', @render

  events:
    'click .edit': 'itemEdit'
    'click a.itemShow, img': 'itemShow'
    'click .remove': 'itemDestroy'
    'click a.commentToggleWrap': -> @toggleWrap('comment')
    'click a.notesToggleWrap': -> @toggleWrap('notes')

  serializeData: ->
    attrs = @model.serializeData()
    attrs.wrap =
      comment:
        wrap: attrs.comment?.length > 120
        nameBase: 'comment'
      notes:
        wrap: attrs.notes?.length > 120
        nameBase: 'notes'
    attrs.username = _.style attrs.username, 'strong'
    return attrs

  itemEdit: -> app.execute 'show:item:form:edition', @model

  itemShow: -> app.execute 'show:item:show:from:model', @model

  itemDestroy: ->
    app.request 'item:destroy',
      model: @model
      selector: @el

  toggleWrap: (nameBase)->
    @$el.find("span.#{nameBase}").toggleClass('wrapped')
    @$el.find("a.#{nameBase}ToggleWrap").find('.fa').toggle()