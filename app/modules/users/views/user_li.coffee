module.exports = class UserLi extends Backbone.Marionette.ItemView
  tagName: "li"
  template: require './templates/user_li'
  className: ->
    status = @model.get('status')
    username = @model.get('username')
    "userLi #{status} #{username}"

  events:
    'click .unfriend': -> app.request 'unfriend', @model
    'click .cancel': -> app.request 'request:cancel', @model
    'click .discard': -> app.request 'request:discard', @model
    'click .accept': -> app.request 'request:accept', @model
    'click .request': -> app.request 'request:send', @model
    'click .select': 'selectUser'

  initialize:->
    @lazyRender = _.debounce @render, 200
    @listenTo @model, 'change', @lazyRender
    @listenTo app.vent, "inventory:#{@model.id}:change", @lazyRender

  serializeData: ->
    attrs = @model.toJSON()
    relationStatus = attrs.status
    # converting the status into a boolean for the template
    attrs[relationStatus] = true
    if relationStatus is 'friends'
      attrs.inventoryLength = app.request 'inventory:user:length', @model.id
    return attrs

  selectUser: ->
    app.execute 'show:inventory:user', @model