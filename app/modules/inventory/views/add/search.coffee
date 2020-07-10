module.exports = Marionette.CompositeView.extend
  id: 'addSearch'
  template: require './templates/search'
  behaviors:
    PreventDefault: {}
    AutoFocus: {}

  childViewContainer: '#history'
  childView: require './previous_search'

  ui:
    history: '#historyWrapper'

  initialize: ->
    @collection = app.searchResultsHistory
    # re-sorting as some timestamps might have be updated
    # since the initial sorting
    @collection.sort()

  onShow: ->
    if @collection.length > 0 then @ui.history.show()
    else @listenToHistory()

  events:
    'click .clearHistory': 'clearHistory'
    'click .search-button': 'showTypeSearch'

  showTypeSearch: (e)->
    type = e.currentTarget.href.split('type=')[1]
    app.execute 'search:global', '', type

  clearHistory: ->
    @collection.reset()
    @ui.history.hide()
    @listenToHistory()

  listenToHistory: ->
    @listenToOnce @collection, 'add', @ui.history.show.bind(@ui.history)
