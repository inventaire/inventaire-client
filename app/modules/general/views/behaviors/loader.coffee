module.exports = class Loader extends Backbone.Marionette.ItemView
  template: require './templates/loader'
  behaviors:
    Loading: {}

  onShow: -> @$el.trigger 'loading'