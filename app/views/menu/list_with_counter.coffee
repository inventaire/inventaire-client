module.exports = class ListWithCounter extends Backbone.Marionette.CompositeView
  template: require './templates/list_with_counter'
  ui:
    counter: '.counter'

  onRender: -> @updateCounter()

  initialize: -> @listenTo @collection, 'all', @updateCounter

  tagName: 'li'
  className: 'has-dropdown not-click'
  childViewContainer: '.dropdown'

  # COUNTER
  updateCounter: ->
    if @collection.length < 1 then @hideCounter()
    else @showCounter()

  hideCounter: -> @ui.counter.hide()
  showCounter: ->
    count = @collection.length.toString()
    @ui.counter.html(count)
    # need to override the style="display:block"
    @ui.counter.slideDown().attr('style', '')