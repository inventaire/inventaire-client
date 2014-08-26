module.exports = class SignupStep2 extends Backbone.Marionette.ItemView
  template: require 'views/behaviors/templates/loader'
  behaviors:
    Loading: {}

  onShow: -> @$el.trigger 'loading'