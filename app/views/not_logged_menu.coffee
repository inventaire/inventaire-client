module.exports = class NotLoggedMenu extends Backbone.Marionette.ItemView
  template: require 'views/templates/not_logged_menu'
  events:
    'click #signupRequest': ->
      console.log 'signup:request'
      app.commands.execute 'signup:request'
    'click #loginRequest': ->
      console.log 'login:request'
      app.commands.execute 'login:request'