module.exports = class Loader extends Backbone.Marionette.ItemView
  template: require 'views/behaviors/templates/loader'
  behaviors:
    Loading: {}

  onShow: ->
    somethingWentWrong = => @$el.trigger('somethingWentWrong')

    @$el.trigger 'loading'
    setTimeout(somethingWentWrong, 16 * 1000)

