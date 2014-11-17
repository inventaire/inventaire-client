module.exports = class Loader extends Backbone.Marionette.ItemView
  template: require 'views/behaviors/templates/loader'
  behaviors:
    Loading: {}

  onShow: -> @$el.trigger 'loading'