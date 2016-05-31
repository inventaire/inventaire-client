# Forked from: https://github.com/KyleNeedham/autocomplete/blob/master/src/autocomplete.collectionview.coffee

# keep in sync with app/modules/general/scss/_autocomplete.scss
listHeight = 170

module.exports = Marionette.CompositeView.extend
  template: require './templates/suggestions'
  className: 'ac-suggestions hidden'
  childViewContainer: 'ul'
  childView: require './suggestion'
  emptyView: require './no_suggestion'
  ui:
    list: 'ul'

  childEvents:
    'highlight': 'scrollToHighlightedChild'
    'select:from:click': 'selectFromClick'

  scrollToHighlightedChild: (child)->
    childTop = child.$el.position().top
    childBottom = childTop + child.$el.height()
    listPosition = @ui.list.scrollTop()
    if childTop < 0 or childBottom > listHeight
      @ui.list.animate { scrollTop: listPosition + childTop - 20 }

  # Pass the child view event to the filtered collection
  selectFromClick: (e, model)-> @collection.trigger 'select:from:click', model
