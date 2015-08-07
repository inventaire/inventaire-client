NotificationsList = require 'modules/notifications/views/notifications_list'
CommonEl = require 'modules/general/regions/common_el'
searchInputData = require './search_input_data'

module.exports = Marionette.LayoutView.extend
  template: require './templates/account_menu'
  events:
    'click #name': -> app.execute 'show:inventory:user', app.user
    'click #editProfile': -> app.execute 'show:settings:profile'
    'click #editLabs': -> app.execute 'show:settings:labs'
    'click #signout': -> app.execute 'logout'

  serializeData: ->
    _.extend @model.toJSON(),
      search: searchInputData()

  initialize: ->
    # /!\ CommonEl custom Regions implies side effects
    # probably limited to the region management functionalities:
    # CommonEl regions insert their views AFTER the attached el
    @addRegion 'notifs', CommonEl.extend {el: '#before-notifications'}

  onShow: ->
    app.execute 'foundation:reload'
    @showNotifications()

  showNotifications: ->
    @notifs.show new NotificationsList
      collection: app.user.notifications
