module.exports = Marionette.LayoutView.extend
  class:'shelfLayout'
  template: require './templates/shelf'

  initialize: ->
    @lazyRender = _.LazyRender @

  regions:
    shelf: '.shelf'

  onRender: ->
    @lazyRender()
