module.exports = Marionette.Behavior.extend
  ui:
    localSearchField: '#localSearchField'

  events:
    'click a#localSearchButton': 'search'
    'inview #localSearchGroup': 'toggleGlobalSearchBar'

  onShow: ->
    # hidding the global bar will be triggered
    # by the 'inview #localSearchGroup' event
    @updateSearchBar()

  search: ->
    app.execute 'search:global', @ui.localSearchField.val()
    app.execute 'last:add:mode:set', 'search'

  updateSearchBar: ->
    @ui.localSearchField.val @view.query

  toggleGlobalSearchBar: (e, isInView)->
    if isInView and not _.smallScreen()
      app.vent.trigger 'search:global:hide'
    else
      # pass local search field val to the global search field
      app.vent.trigger 'search:global:show', @ui.localSearchField.val()
