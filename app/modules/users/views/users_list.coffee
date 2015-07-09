module.exports = Marionette.CollectionView.extend
  tagName: 'ul'
  className: 'usersList'
  childView: require './user_li'
  childViewOptions: ->
    groupContext: @options.groupContext
    group: @options.group
  emptyView: require './no_user'
  emptyViewOptions: ->
    message: @options.emptyViewMessage or "can't find anyone with that name"

  initialize: ->
    if @options.filter? then @filter = @options.filter
  onShow: -> app.execute 'foundation:reload'