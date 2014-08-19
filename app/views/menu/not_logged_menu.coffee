module.exports = class NotLoggedMenu extends Backbone.Marionette.ItemView
  template: require 'views/menu/templates/not_logged_menu'
  events:
    'click #signupRequest': -> app.execute 'signup:request'
    'click #loginRequest': -> app.execute 'login:request'
  onShow: -> app.execute 'foundation:reload'