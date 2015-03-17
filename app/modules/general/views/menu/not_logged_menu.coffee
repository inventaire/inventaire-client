module.exports = class NotLoggedMenu extends Backbone.Marionette.ItemView
  template: require './templates/not_logged_menu'
  events:
    'click #signupRequest': -> app.execute 'show:signup'
    'click #loginRequest': -> app.execute 'show:login'
  onShow: -> app.execute 'foundation:reload'