NotificationsList = require 'modules/notifications/views/notifications_list'
CommonEl = require 'modules/general/regions/common_el'
searchInputData = require './search_input_data'
urls = require 'lib/urls'
sectionWithLocalSearch = [ 'search', 'add' ]

module.exports = Marionette.LayoutView.extend
  template: require './templates/account_menu'
  events:
    'click #name': 'selectMainUser'
    'click #editProfile': -> app.execute 'show:settings:profile'
    'click #editNotifications': -> app.execute 'show:settings:notifications'
    'click #editLabs': -> app.execute 'show:settings:labs'
    'click #signout': -> app.execute 'logout'
    'click a#searchButton': 'search'

  behaviors:
    PreventDefault: {}

  serializeData: ->
    _.extend @model.toJSON(),
      search: searchInputData()
      urls: urls

  initialize: ->
    # /!\ CommonEl custom Regions implies side effects
    # probably limited to the region management functionalities:
    # CommonEl regions insert their views AFTER the attached el
    @addRegion 'notifs', CommonEl.extend {el: '#before-notifications'}

    @listenTo app.vent, 'search:local:show', @hideGlobalSearch.bind(@)
    @listenTo app.vent, 'search:local:hide', @showGlobalSearch.bind(@)

  onShow: ->
    app.execute 'foundation:reload'
    @showNotifications()
    if _.currentSection() in sectionWithLocalSearch then @hideGlobalSearch()

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

  showGlobalSearch: -> @ui.searchGroup.show()
  hideGlobalSearch: -> @ui.searchGroup.hide()
