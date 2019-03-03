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
    localSearchField: '#localSearchField'

  initialize: ->
    @collection = app.searchResultsHistory
    # re-sorting as some timestamps might have be updated
    # since the initial sorting
    @collection.sort()

    @previousValue = ''
    @listenTo app.vent, 'search:global:change', @updateLocalSearchBar.bind(@)

  onShow: ->
    if @collection.length > 0 then @ui.history.show()
    else @listenToHistory()

  serializeData: ->
    search: searchInputData()

  events:
    'keyup input[type="search"]': 'focusGlobalSearchBar'
    'click .clearHistory': 'clearHistory'
    # As the search input is synchronized with the top bar input
    # let that one handle the search
    'click #localSearchButton': -> app.layout.topBar.currentView.search()

  updateLocalSearchBar: (value)->
    @ui.localSearchField.val value
    @previousValue = value

  focusGlobalSearchBar: (e)->
    currentValue = e.currentTarget.value
    if currentValue is @previousValue then return
    @previousValue = currentValue
    $('#searchField').val(currentValue).focus()

  clearHistory: ->
    @collection.reset()
    @ui.history.hide()
    @listenToHistory()

  listenToHistory: ->
    @listenToOnce @collection, 'add', @ui.history.show.bind(@ui.history)

searchInputData = ->
  nameBase: 'localSearch'
  field:
    type: 'search'
    name: 'search'
    placeholder: _.i18n 'search a book by title, author or ISBN'
  button:
    icon: 'search'
    classes: 'secondary postfix'
