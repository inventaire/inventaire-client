module.exports = class AccountMenu extends Backbone.Marionette.ItemView
  template: require 'views/menu/templates/account_menu'
  events:
    'click #edit': -> app.commands.execute 'user:edit'
    'click #logout': -> app.commands.execute 'persona:logout'
  onShow: -> app.commands.execute 'foundation:reload'