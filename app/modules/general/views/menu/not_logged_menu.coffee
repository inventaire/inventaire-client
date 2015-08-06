module.exports = Marionette.ItemView.extend
  template: require './templates/not_logged_menu'
  className: 'notLoggedMenu'
  events:
    'click #signupRequest': -> app.execute 'show:signup'
    'click #loginRequest': -> app.execute 'show:login'
  onShow: -> app.execute 'foundation:reload'
