{ translate } = require 'lib/urls'
showViews = require '../lib/show_views'
getActionKey = require 'lib/get_action_key'

{ languages } = require 'lib/active_languages'
mostCompleteFirst = (a, b)-> b.completion - a.completion
languagesList = _.values(languages).sort mostCompleteFirst

module.exports = Marionette.LayoutView.extend
  id: 'top-bar'
  tagName: 'nav'
  className: -> if app.user.loggedIn then 'logged-in' else ''
  template: require './templates/top_bar'

  ui:
    searchGroup: '#searchGroup'
    searchField: '#searchField'

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

    @listenTo app.user, 'change:username', @lazyRender
    @listenTo app.user, 'change:picture', @lazyRender

  serializeData: ->
    smallScreen: _.smallScreen()
    isLoggedIn: app.user.loggedIn
    search: searchInputData()
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
    'focus #searchField': -> app.execute 'live:search:focus'
    'focusout #searchField': (e)-> app.execute 'live:search:unfocus', e
    'keydown #searchField': 'onKeyDown'

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

  onKeyDown: (e)->
    key = getActionKey e
    # Prevent the cursor to move when using special keys
    # to navigate the live_search list
    if key in neutralizedKey then e.preventDefault()
    app.execute 'live:search:keydown', e

neutralizedKey = [ 'up', 'down' ]

hasLocalSearch = (section, route)->
  if section is 'search' then return true
  if /^add\/search/.test route  then return true
  return false

searchInputData = ->
  nameBase: 'search'
  special: true
  field:
    type: 'search'
    name: 'search'
    placeholder: _.i18n 'search a book by title, author or ISBN'
  button:
    icon: 'search'
    # text: '<span class="text">' + _.I18n('search') + '</span>'
    classes: "secondary postfix"
