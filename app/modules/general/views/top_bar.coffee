{ translate } = require 'lib/urls'
showViews = require '../lib/show_views'
getActionKey = require 'lib/get_action_key'
LiveSearch = require 'modules/search/views/live_search'
TopBarButtons = require './top_bar_buttons'
screen_ = require 'lib/screen'
{ currentRoute, currentSection } = require 'lib/location'

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
    topBarButtons: '#topBarButtons'

  ui:
    searchField: '#searchField'
    overlay: '#overlay'
    closeSearch: '.closeSearch'

  initialize: ->

    @listenTo app.vent,
      'screen:mode:change': @lazyRender.bind(@)
      'route:change': @onRouteChange.bind(@)
      'live:search:show:result': @hideLiveSearch.bind(@)
      'live:search:query': @setQuery.bind(@)

    @listenTo app.user, 'change:picture', @lazyRender.bind(@)

  serializeData: ->
    smallScreen: screen_.isSmall()
    isLoggedIn: app.user.loggedIn
    currentLanguage: languages[app.user.lang].native
    languages: languagesList
    translate: translate

  onRender: ->
    if app.user.loggedIn then @showTopBarButtons()
    # Needed as 'route:change' might have been triggered before
    # this view was initialized
    @onRouteChange currentSection(), currentRoute()

  showTopBarButtons: ->
    # Use a child view for those buttons to be able to re-render them independenly
    # without disrupting the LiveSearch state
    @topBarButtons.show new TopBarButtons

  onRouteChange: (section, route)->
    @updateConnectionButtons section

  events:
    'click #home': _.clickCommand 'show:home'

    'focus #searchField': 'showLiveSearch'
    'keyup #searchField': 'onKeyUp'
    'keydown #searchField': 'onKeyDown'
    'click .searchFilter': 'recoverSearchFocus'
    'click': 'updateLiveSearch'
    'click .closeSearch': 'closeSearch'
    'click #live-search': 'closeSearchOnOverlayClick'

    'click .language-picker .option a': 'selectLang'

  childEvents:
    'hide:live:search': 'hideLiveSearch'

  updateConnectionButtons: (section)->
    if app.user.loggedIn then return

    if screen_.isSmall() and (section is 'signup' or section is 'login')
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

  showLiveSearch: (params = {})->
    # If a section is specified, reinitialize the search view
    # to take that section request into account
    if @liveSearch.currentView? and not params.section? then @liveSearch.$el.show()
    else @liveSearch.show new LiveSearch(params)
    @liveSearch.$el.addClass 'shown'
    @liveSearch.currentView.resetHighlightIndex()
    @ui.overlay.removeClass 'hidden'
    @ui.closeSearch.removeClass 'hidden'
    @_liveSearchIsShown = true

  hideLiveSearch: (triggerFallbackLayout)->
    # Discard non-boolean flags
    triggerFallbackLayout = triggerFallbackLayout is true and currentRoute() is 'search'

    unless @liveSearch.$el? then return

    @liveSearch.$el.hide()
    @liveSearch.$el.removeClass 'shown'
    @ui.overlay.addClass 'hidden'
    @ui.closeSearch.addClass 'hidden'
    @_liveSearchIsShown = false
    # Trigger the fallback layout only in cases when no other layout
    # is set to be displayed
    if triggerFallbackLayout and @showFallbackLayout?
      @showFallbackLayout()
      @showFallbackLayout = null

  updateLiveSearch: (e)->
    # Make clicks on anything but the search group hide the live search
    { target } = e
    if target.id is 'overlay' or $(target).parents('#searchGroup').length is 0
      @hideLiveSearch true

  onKeyDown: (e)->
    # Prevent the cursor to move when using special keys
    # to navigate the live_search list
    key = getActionKey e
    if key in neutralizedKeys then e.preventDefault()

  onKeyUp: (e)->
    unless @_liveSearchIsShown then @showLiveSearch()

    key = getActionKey e
    if key?
      if key is 'esc' then @hideLiveSearch true
      else @liveSearch.currentView.onSpecialKey key
    else
      { value } = e.currentTarget
      @searchLive value

  searchLive: (text)->
    @liveSearch.currentView.lazySearch text
    app.vent.trigger 'search:global:change', text

  setQuery: (params)->
    { search, @showFallbackLayout, section } = params
    @showLiveSearch { section }
    @searchLive search
    @ui.searchField.focus()
    # Set value after focusing so that the cursor appears at the end
    # cf https://stackoverflow.com/a/8631903/3324977inv
    @ui.searchField.val search

  # When clicking on a live_search searchField button, the search loose the focus
  # thus the need to recover it
  recoverSearchFocus: -> @ui.searchField.focus()

  closeSearch: ->
    @ui.searchField.val ''
    @hideLiveSearch()

  # If the click event is directly on the live search element
  # that means that it was outside the search results or sections
  # and should be interpreted as a close request
  # This can be the case on small screens as #live-search takes all the height
  # and thus clicks on #overlay won't be detected
  closeSearchOnOverlayClick: (e)->
    if e.target.id is 'live-search' then @closeSearch()

neutralizedKeys = [ 'up', 'down', 'pageup', 'pagedown' ]
