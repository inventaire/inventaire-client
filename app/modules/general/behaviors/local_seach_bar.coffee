module.exports = Marionette.Behavior.extend
  ui:
    localSearchField: '#localSearchField'

  events:
    'click a#localSearchButton': 'search'

  onShow: ->
    app.vent.trigger 'search:local:show'
    @updateSearchBar()

  onDestroy: ->
    app.vent.trigger 'search:local:hide'

  search: ->
    app.execute 'search:global', @ui.localSearchField.val()
    app.execute 'last:add:mode:set', 'search'

  updateSearchBar: ->
    @ui.localSearchField.val @view.query
