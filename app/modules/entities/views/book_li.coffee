module.exports = Marionette.ItemView.extend
  template: require './templates/book_li'
  tagName: 'li'
  className: 'bookLi'

  initialize: ->
    @listenTo @model, 'change', @render
    @listenTo @model, 'add:pictures', @render
    app.request('qLabel:update')

  behaviors:
    PreventDefault: {}

  events:
    'click a.addToInventory': 'showItemCreationForm'

  showItemCreationForm: (e)->
    unless _.isOpenedOutside(e)
      app.execute 'show:item:creation:form', {entity: @model}

  serializeData: ->
    attrs = @model.toJSON()
    if attrs.extract? then attrs.description = attrs.extract
    return attrs
