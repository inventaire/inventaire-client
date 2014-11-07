module.exports = class UsersList extends Backbone.Marionette.CollectionView
  tagName: 'ul'
  className: 'usersList'
  childView: require 'views/users/user_li'
  emptyView: require 'views/users/no_user'