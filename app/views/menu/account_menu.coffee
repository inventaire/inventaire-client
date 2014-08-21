module.exports = class AccountMenu extends Backbone.Marionette.ItemView
  template: require 'views/menu/templates/account_menu'
  events:
    'click #edit': -> app.execute 'show:user:edit'
    'click #logout': -> app.execute 'persona:logout'
  onShow: -> app.execute 'foundation:reload'