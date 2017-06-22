module.exports = Marionette.CompositeView.extend
  className: 'notifications has-dropdown'
  template: require './templates/notifications_list'
  childViewContainer: 'ul'
  childView: require './notification_li'
  emptyView: require './no_notification'
  ui:
    counter: '.counter'
    list: 'ul'

  initialize: ->
    @initUpdaters()

  initUpdaters: ->
    @listenTo @collection, 'all', @updateCounter

  events:
    'click': 'markNotificationsAsRead'
    'click .seeAll': 'showAllNotification'

  onRender: -> @updateCounter()

  markNotificationsAsRead: -> @collection.markAsRead()

  updateCounter: ->
    if @collection.unreadCount() is 0 then @hideCounter()
    else @showCounter()

  hideCounter: -> @ui.counter.hide()

  showCounter: ->
    @ui.counter.html @collection.unreadCount()
    # need to override the style="display:block"
    @ui.counter.slideDown().attr('style', '')

  filter: (child, index, collection)->
    if child.isUnread() then true
    else -1 < index < 5

  showAllNotification: -> app.execute 'show:notifications'
