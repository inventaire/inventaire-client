module.exports = class NotLoggedMenu extends Backbone.Marionette.ItemView
  template: require './templates/not_logged_menu'
  events:
    'click #signupRequest': -> app.execute 'show:signup:step1'
    'click #loginRequest': -> app.execute 'show:login:step1'
  onShow: -> app.execute 'foundation:reload'