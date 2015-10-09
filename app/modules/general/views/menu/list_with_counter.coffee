module.exports = Marionette.CompositeView.extend
  template: require './templates/list_with_counter'
  ui:
    counter: '.counter'
    list: 'ul'

  onRender: -> @updateCounter()

  initialize: -> @initUpdaters()

  initUpdaters: ->
    @listenTo @collection, 'all', @updateCounter

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
