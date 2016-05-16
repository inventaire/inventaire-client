searchInputData = require 'modules/general/views/menu/search_input_data'

module.exports = Marionette.CompositeView.extend
  id: 'addSearch'
  template: require './templates/search'
  behaviors:
    PreventDefault: {}
    LocalSeachBar: {}
    AutoFocus: {}

  childViewContainer: '#history'
  childView: require './previous_search'

  ui:
    history: '#historyWrapper'

  initialize: ->
    @collection = app.searches
    # re-sorting as some timestamps might have be updated
    # since the initial sorting
    @collection.sort()

  onShow: ->
    if @collection.length > 0 then @ui.history.show()
    else @listenToHistory()

  serializeData: ->
    search: searchInputData 'localSearch', true

  events:
    'click .clearHistory': 'clearHistory'

  clearHistory: ->
    @collection.reset()
    @ui.history.hide()
    @listenToHistory()

  listenToHistory: ->
    @listenToOnce @collection, 'add', @ui.history.show.bind(@ui.history)
