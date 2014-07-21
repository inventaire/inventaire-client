module.exports = class LoginStep1 extends Backbone.Marionette.ItemView
  tagName: 'div'
  template: require 'views/user/templates/login_step1'
  onShow: ->
    app.commands.execute 'modal:open'
  events:
    'click #loginPersona': -> app.execute 'persona:login'