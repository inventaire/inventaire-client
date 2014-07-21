module.exports = class NotLoggedMenu extends Backbone.Marionette.ItemView
  template: require 'views/menu/templates/not_logged_menu'
  events:
    'click #signupRequest': -> app.commands.execute 'signup:request'
    'click #loginRequest': -> app.commands.execute 'login:request'
  onShow: -> app.commands.execute 'foundation:reload'