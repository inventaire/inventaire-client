module.exports = class AccountMenu extends Backbone.Marionette.ItemView
  tagName: 'li'
  className: 'has-dropdown'
  template: require 'views/templates/account_menu'
  events:
    'click #logout': -> app.vent.trigger 'persona:logout'