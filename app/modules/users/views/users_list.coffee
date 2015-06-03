module.exports = Marionette.CollectionView.extend
  tagName: 'ul'
  className: 'usersList'
  childView: require './user_li'
  emptyView: require './no_user'
  onShow: -> app.execute 'foundation:reload'