module.exports = Loader = Backbone.Marionette.ItemView.extend
  template: require './templates/loader'
  behaviors:
    Loading: {}

  onShow: -> @$el.trigger 'loading'