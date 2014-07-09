module.exports = class NotLoggedMenu extends Backbone.Marionette.ItemView
  tagName: 'li'
  template: require 'views/templates/not_logged_menu'
  events:
    'click #signupRequest': -> app.vent.trigger 'signup:request'
    'click #loginRequest': -> app.vent.trigger 'login:request'