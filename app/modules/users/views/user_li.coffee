relationsActions = require '../plugins/relations_actions'

module.exports = Marionette.ItemView.extend
  tagName: 'li'
  template: require './templates/user_li'
  className: ->
    status = @model.get 'status'
    username = @model.get 'username'
    "userLi #{status} #{username}"

  behaviors:
    PreventDefault: {}
    ConfirmationModal: {}

  events:
    'click .select': 'selectUser'

  initialize:->
    @initPlugins()
    @lazyRender = _.debounce @render, 200
    @listenTo @model, 'change', @lazyRender
    @listenTo app.vent, "inventory:#{@model.id}:change", @lazyRender

  initPlugins: ->
    relationsActions.call @

  onShow: ->
    app.execute 'foundation:reload'

  serializeData: ->
    @model.serializeData()

  selectUser: (e)->
    unless _.isOpenedOutside(e)
      app.execute 'show:inventory:user', @model
