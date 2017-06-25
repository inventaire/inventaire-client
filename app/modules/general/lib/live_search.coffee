LiveSearch = require 'modules/search/views/live_search'
getActionKey = require 'lib/get_action_key'

module.exports = ->
  $overlay = $('#overlay')
  $topbar = $('#top-bar')

  view = null
  isShown = false

  show = ->
    $topbar.addClass 'searchFocused'
    $overlay.removeClass 'hidden'
    unless view?
      view = new LiveSearch
      app.layout.overlay.show view
    isShown = true

  hide = ->
    $topbar.removeClass 'searchFocused'
    $overlay.addClass 'hidden'
    isShown = false

  # Hide on click if target is overlay
  $overlay.on 'click', (e)-> if e.target.id is 'overlay' then hide()

  focusSearch = -> show()

  unfocusSearch = (e)->
    # Unfocus only if an other element in the page got the focus,
    # not if the focus went to another tab/window, so that when
    # coming back, there is no style jump from re-focusing the search bar
    if $(':focus').length is 0 then return
    hide()

  lazyUpdateSearch = null

  keydown = (e)->
    unless isShown
      show()
      view.resetHighlightIndex()

    lazyUpdateSearch or= _.debounce view.search.bind(view), 100

    key = getActionKey e
    if key?
      switch key
        when 'up' then view.highlightPrevious()
        when 'down' then view.highlightNext()
        when 'enter' then view.showCurrentlyHighlightedResult()
        when 'esc' then unfocusSearch()
        else return
    else
      lazyUpdateSearch e.currentTarget.value


  app.commands.setHandlers
    'live:search:focus': focusSearch
    'live:search:unfocus': unfocusSearch
    'live:search:keydown': _.debounce keydown, 100
