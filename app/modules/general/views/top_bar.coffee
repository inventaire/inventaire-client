searchInputData = require './menu/search_input_data'
NotificationsList = require 'modules/notifications/views/notifications_list'
SettingsMenu = require './settings_menu'
{ translate } = require 'lib/urls'
showViews = require '../lib/show_views'

{ languages } = require 'lib/active_languages'
mostCompleteFirst = (a, b)-> b.completion - a.completion
languagesList = _.values(languages).sort mostCompleteFirst

module.exports = Marionette.LayoutView.extend
  id: 'top-bar'
  tagName: 'nav'
  className: -> if app.user.loggedIn then 'logged-in' else ''
  template: require './templates/top_bar'
  regions:
    notificationsMenu: '#notifications-menu'

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
      'route:change': @updateGlobalSearch.bind(@)

    @listenTo app.user, 'change:username', @lazyRender
    @listenTo app.user, 'change:picture', @lazyRender

  serializeData: ->
    smallScreen: _.smallScreen()
    isLoggedIn: app.user.loggedIn
    search: searchInputData null, true
    user: app.user.toJSON()
    currentLanguage: languages[app.user.lang].native
    languages: languagesList
    translate: translate

  onShow: ->
    # Needed as 'route:change' might have been triggered before
    # this view was initialized
    @updateGlobalSearch _.currentSection(), _.currentRoute()

  onRender: ->
    if _.smallScreen() then return
    if app.user.loggedIn then @showNotifications()

  showNotifications: ->
    @notificationsMenu.show new NotificationsList { collection: app.notifications }

  events:
    'click #mainUser': 'showMainUser'
    'click #settings-menu': showViews.showSettingsMenu
    'click a#searchButton': 'search'
    'click .option a': 'selectLang'

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

  selectLang: (e)->
    lang = e.currentTarget.attributes['data-lang'].value
    if app.user.loggedIn
      app.request 'user:update',
        attribute:'language'
        value: lang
        selector: '#languagePicker'
    else
      app.user.set 'language', lang

hasLocalSearch = (section, route)->
  if section is 'search' then return true
  if /^add\/search/.test route  then return true
  return false
