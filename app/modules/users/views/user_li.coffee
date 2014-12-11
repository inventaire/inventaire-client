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
    @listenTo @model, 'change', @render

  serializeData: ->
    attrs = @model.toJSON()
    status = attrs.status
    # converting the status into a boolean for the template
    attrs[status] = true
    return attrs

  selectUser: ->
    app.execute 'show:inventory:user', @model