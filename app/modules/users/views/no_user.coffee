module.exports = class NoUser extends Backbone.Marionette.ItemView
  tagName: 'li'
  className: 'text-center hidden'
  template: require './templates/no_user'
  onShow: -> @$el.fadeIn()