module.exports = class AccountMenu extends Backbone.Marionette.ItemView
  template: require 'views/menu/templates/account_menu'
  events:
    'click #logout': -> app.commands.execute 'persona:logout'