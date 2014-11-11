module.exports = class NotificationsList extends Backbone.Marionette.CompositeView
  template: require './templates/notifications_list'

  # will be overriden by the CommonEl el
  # but still needed so that the ui selectors can use it
  # el: '#notifications'

  ui:
    counter: '.counter'

  onRender: -> @updateCounter()

  initialize: ->
    @listenTo @collection,  'all', @render

  # COUNTER

  updateCounter: ->
    if @collection.length < 1 then @hideCounter()
    else @showCounter()

  hideCounter: -> @ui.counter.hide()
  showCounter: ->
    count = @collection.length.toString()
    @ui.counter.html(count)
    @ui.counter.slideDown()

  # NOTIFICATIONS

  childViewContainer: '.dropdown'
  childView: require './notification_li'
  emptyView: require './no_notification'