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
  count: -> @collection.length
  updateCounter: ->
    if @count() is 0 then @hideCounter()
    else @showCounter()

  hideCounter: -> @ui.counter.hide()
  showCounter: ->
    @ui.counter.html @count()
    # need to override the style="display:block"
    @ui.counter.slideDown().attr('style', '')
