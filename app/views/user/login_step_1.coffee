module.exports = class LoginStep1 extends Backbone.Marionette.ItemView
  tagName: 'div'
  template: require 'views/user/templates/login_step1'
  # onShow: -> app.execute 'modal:open'
  events:
    'click #loginPersona': 'waitingForPersona'
  behaviors:
    Loading: {}

  waitingForPersona:->
    app.execute 'persona:login'
    @$el.trigger 'loading',
      message: _.i18n('a popup should now open to let you verify your credentials')