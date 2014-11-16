module.exports = class UsersList extends Backbone.Marionette.CollectionView
  tagName: 'ul'
  className: 'usersList'
  childView: require './user_li'
  emptyView: require './no_user'