module.exports = Marionette.ItemView.extend
  template: require './templates/no_group'
  className: 'noGroup'
  tagName: 'li'
  behaviors:
    PreventDefault: {}

  serializeData: ->
    message: @options.message
  onShow: ->
    @$el.hide().fadeIn()

  events:
    'click #create': 'showGroupCreate'

  showGroupCreate: (e)->
    unless _.isOpenedOutside e
      app.execute 'show:group:create'
