module.exports = Backbone.Marionette.ItemView.extend
  template: require './templates/items_control'
  className: 'itemsControl'

  initialize: ->
    @listenTo app.vent, 'items:list:before:after', @render

  serializeData: ->
    before = app.request 'items:pagination:before'
    after = app.request 'items:pagination:after'
    attrs =
      pagination: before > 0 or after > 0
      prevStatus: unless before > 0 then 'disabled'
      nextStatus: unless after > 0 then 'disabled'
    return attrs

  events:
    'click .prev': 'prev'
    'click .next': 'next'

  prev: ->
    before = app.request 'items:pagination:before'
    if before > 0 then app.execute 'items:pagination:prev'

  next: ->
    after = app.request 'items:pagination:after'
    if after > 0 then app.execute 'items:pagination:next'