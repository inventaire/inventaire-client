{ translate } = require 'lib/urls'
showViews = require '../lib/show_views'
getActionKey = require 'lib/get_action_key'
LiveSearch = require 'modules/search/views/live_search'

{ languages } = require 'lib/active_languages'
mostCompleteFirst = (a, b)-> b.completion - a.completion
languagesList = _.values(languages).sort mostCompleteFirst

module.exports = Marionette.LayoutView.extend
  id: 'top-bar'
  tagName: 'nav'
  className: -> if app.user.loggedIn then 'logged-in' else ''
  template: require './templates/top_bar'

  regions:
    liveSearch: '#liveSearch'

  ui:
    searchGroup: '#searchGroup'
    searchField: '#searchField'
    overlay: '#overlay'

  initialize: ->
    @lazyRender = _.LazyRender @

    @listenTo app.vent,
      'screen:mode:change': @lazyRender
      'search:global:show': @showGlobalSearch.bind(@)
      'search:global:hide': @hideGlobalSearch.bind(@)
      # heavier but cleaner than asking the concerned views to call
      # 'search:global:show' and 'search:global:hide' onShow and onDestroy
      # as re-showing the view creates an ugly hide/show/hide sequence
      'route:change': @onRouteChange.bind(@)
      'live:search:show:result': @onSearchUnfocus.bind(@)

    @listenTo app.user, 'change:username', @lazyRender
    @listenTo app.user, 'change:picture', @lazyRender

  serializeData: ->
    smallScreen: _.smallScreen()
    isLoggedIn: app.user.loggedIn
    user: app.user.toJSON()
    currentLanguage: languages[app.user.lang].native
    languages: languagesList
    translate: translate

  onShow: ->
    # Needed as 'route:change' might have been triggered before
    # this view was initialized
    @onRouteChange _.currentSection(), _.currentRoute()

  onRouteChange: (section, route)->
    @updateGlobalSearch section, route
    @updateConnectionButtons section

  events:
    'click #mainUser': 'showMainUser'
    # Disabled for development
    # 'click a#searchButton': 'search'
    'click .option a': 'selectLang'
    'focus #searchField': 'showLiveSearch'
    'focusout #searchField': 'onSearchUnfocus'
    'keyup #searchField': 'onKeyUp'
    'click #overlay': 'hideSearchOnOverlayClick'

  showMainUser: (e)->
    unless _.isOpenedOutside e
      app.execute 'show:inventory:user', app.user

  search: ->
    query = @ui.searchField.val()
    app.execute 'search:global', query

  showGlobalSearch: (query)->
    @ui.searchGroup.fadeIn(200)
    if _.isNonEmptyString(query) then @ui.searchField.val query

  hideGlobalSearch: -> @ui.searchGroup.fadeOut(200)

  updateGlobalSearch: (section, route)->
    if hasLocalSearch(section, route) and not _.smallScreen()
      @hideGlobalSearch()
    else
      @showGlobalSearch()

  updateConnectionButtons: (section)->
    if app.user.loggedIn then return

    if _.smallScreen() and (section is 'signup' or section is 'login')
      $('.connectionButton').hide()
    else if not app.user.loggedIn
      $('.connectionButton').show()

  selectLang: (e)->
    lang = e.currentTarget.attributes['data-lang'].value
    if app.user.loggedIn
      app.request 'user:update',
        attribute:'language'
        value: lang
        selector: '#languagePicker'
    else
      app.user.set 'language', lang

  showLiveSearch: ->
    if @liveSearch.currentView? then @liveSearch.$el.show()
    else @liveSearch.show new LiveSearch
    @liveSearch.currentView.resetHighlightIndex()
    @ui.overlay.removeClass 'hidden'
    @_liveSearchIsShown = true

  onSearchUnfocus: ->
    # Unfocus only if an other element in the page got the focus,
    # not if the focus went to another tab/window, so that when
    # coming back, there is no style jump from re-focusing the search bar
    if $(':focus').length is 0 then return
    @hideLiveSearch()

  hideLiveSearch: ->
    @liveSearch.$el.hide()
    @ui.overlay.addClass 'hidden'
    @_liveSearchIsShown = false

  hideSearchOnOverlayClick: (e)-> if e.target.id is 'overlay' then @hideLiveSearch()

  onKeyUp: (e)->
    key = getActionKey e
    # Prevent the cursor to move when using special keys
    # to navigate the live_search list
    if key in neutralizedKey then e.preventDefault()

    unless @_liveSearchIsShown then @showLiveSearch()

    view = @liveSearch.currentView

    key = getActionKey e
    if key?
      switch key
        when 'up' then view.highlightPrevious()
        when 'down' then view.highlightNext()
        when 'enter' then view.showCurrentlyHighlightedResult()
        when 'esc' then @hideLiveSearch()
        else return
    else
      view.lazySearch e.currentTarget.value

neutralizedKey = [ 'up', 'down' ]

hasLocalSearch = (section, route)->
  if section is 'search' then return true
  if /^add\/search/.test route  then return true
  return false
