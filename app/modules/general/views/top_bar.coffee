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
    searchField: '#searchField'
    overlay: '#overlay'

  initialize: ->
    @lazyRender = _.LazyRender @

    @listenTo app.vent,
      'screen:mode:change': @lazyRender
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
    @updateConnectionButtons section

  events:
    'click #home': 'showHome'
    'click #mainUser': 'showMainUser'
    'click a#searchButton': 'search'
    'click .option a': 'selectLang'
    'focus #searchField': 'showLiveSearch'
    'focusout #searchField': 'onSearchUnfocus'
    'keyup #searchField': 'onKeyUp'
    'keydown #searchField': 'onKeyDown'
    'click #overlay': 'hideSearchOnOverlayClick'
    'click .searchFilter': 'recoverSearchFocus'

  childEvents:
    'enter:without:hightlighed:result': 'search'

  showHome: (e)->
    unless _.isOpenedOutside e
      app.execute 'show:home'
      # When the live search is visible, clicking #home might be an attempt
      # to close it
      @onSearchUnfocus()

  showMainUser: (e)->
    unless _.isOpenedOutside e
      app.execute 'show:inventory:user', app.user

  search: ->
    @hideLiveSearch()
    search = @ui.searchField.val()
    unless _.isNonEmptyString search then return
    app.execute 'search:global', search

  updateConnectionButtons: (section)->
    if app.user.loggedIn then return

    if _.smallScreen() and (section is 'signup' or section is 'login')
      $('.connectionButton').hide()
    else if not app.user.loggedIn
      $('.connectionButton').show()

  selectLang: (e)->
    # Remove the querystring lang parameter to be sure that the picked language
    # is the next language taken in account
    app.execute 'querystring:set', 'lang', null

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

  onKeyDown: (e)->
    # Prevent the cursor to move when using special keys
    # to navigate the live_search list
    key = getActionKey e
    if key in neutralizedKeys then e.preventDefault()

  onKeyUp: (e)->
    unless @_liveSearchIsShown then @showLiveSearch()

    view = @liveSearch.currentView
    key = getActionKey e
    if key?
      if key is 'esc' then @hideLiveSearch()
      else return view.onSpecialKey key
    else
      { value } = e.currentTarget
      view.lazySearch value
      app.vent.trigger 'search:global:change', value

  # When clicking on a live_search searchField button, the search loose the focus
  # thus the need to recover it
  recoverSearchFocus: -> @ui.searchField.focus()

neutralizedKeys = [ 'up', 'down', 'pageup', 'pagedown' ]
