module.exports = class ListWithCounter extends Backbone.Marionette.CompositeView
  template: require './templates/list_with_counter'
  # will be overriden by the CommonEl el
  # but still needed so that the ui selectors can use it
  # => an el should be provided at view instanciation
  # el: '#notifications'

  ui:
    counter: '.counter'

  onRender: -> @updateCounter()

  initialize: -> @listenTo @collection, 'add', @render

  # COUNTER
  updateCounter: ->
    if @collection.length < 1 then @hideCounter()
    else @showCounter()

  hideCounter: -> @ui.counter.hide()
  showCounter: ->
    count = @collection.length.toString()
    @ui.counter.html(count)
    @ui.counter.slideDown()