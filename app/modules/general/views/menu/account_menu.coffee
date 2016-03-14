NotificationsList = require 'modules/notifications/views/notifications_list'
CommonEl = require 'modules/general/regions/common_el'
searchInputData = require './search_input_data'
urls = require 'lib/urls'

module.exports = Marionette.LayoutView.extend
  template: require './templates/account_menu'
  events:
    'click #name': 'selectMainUser'
    'click #editProfile': -> app.execute 'show:settings:profile'
    'click #editNotifications': -> app.execute 'show:settings:notifications'
    'click #editLabs': -> app.execute 'show:settings:labs'
    'click #signout': -> app.execute 'logout'
    'click a#searchButton': 'search'
    'click .showWelcome': 'closeMenu'

  behaviors:
    PreventDefault: {}

  serializeData: ->
    _.extend @model.toJSON(),
      search: searchInputData()
      urls: urls
      smallScreen: _.smallScreen()

  initialize: ->
    # /!\ CommonEl custom Regions implies side effects
    # probably limited to the region management functionalities:
    # CommonEl regions insert their views AFTER the attached el
    @addRegion 'notifs', CommonEl.extend {el: '#before-notifications'}

    @listenTo app.vent,
      'window:resize': @render
      'search:global:show': @showGlobalSearch.bind(@)
      'search:global:hide': @hideGlobalSearch.bind(@)
      # heavier but cleaner than asking the concerned views to call
      # 'search:global:show' and 'search:global:hide' onShow and onDestroy
      # as re-showing the view creates an ugly hide/show/hide sequence
      'route:change': @updateGlobalSearch.bind(@)

  onShow: ->
    app.execute 'foundation:reload'
    @showNotifications()
    # needed as 'route:change' might have been triggered before
    # this view was initialized
    @updateGlobalSearch _.currentSection(), _.currentRoute()

  showNotifications: ->
    @notifs.show new NotificationsList
      collection: app.user.notifications

  selectMainUser: (e)->
    unless _.isOpenedOutside(e)
      app.execute 'show:inventory:user', app.user
  ui:
    searchGroup: '#searchGroup'
    searchField: '#searchField'

  search: ->
    query = @ui.searchField.val()
    app.execute 'search:global', query

  showGlobalSearch: (query)->
    @ui.searchGroup.fadeIn(200)
    if _.isNonEmptyString(query) then @ui.searchField.val query

  hideGlobalSearch: -> @ui.searchGroup.fadeOut(200)

  updateGlobalSearch: (section, route)->
    if hasLocalSearch(section, route) then @hideGlobalSearch()
    else @showGlobalSearch()

  # let the event propagate to app_layout, which will trigger show:welcome
  closeMenu: ->
    if _.smallScreen()
      # close the topbar menu handled by Foundation
      $('.toggle-topbar').trigger 'click'

hasLocalSearch = (section, route)->
  if section is 'search' then return true
  if /^add\/search/.test route  then return true
  return false
