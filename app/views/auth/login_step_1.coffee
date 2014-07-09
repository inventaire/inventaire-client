module.exports = class LoginStep1 extends Backbone.Marionette.ItemView
  tagName: 'div'
  template: require 'views/auth/templates/login_step1'
  events:
    'click #loginPersona': 'loginPersona'

  loginPersona: ()->
    app.vent.trigger 'persona:request'