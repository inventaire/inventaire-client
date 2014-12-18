RequestsList = require 'modules/users/views/requests_list'
NotificationsList = require 'modules/notifications/views/notifications_list'
CommonEl = require 'modules/general/regions/common_el'
scanner = require 'lib/scanner'

module.exports = class AccountMenu extends Backbone.Marionette.LayoutView
  template: require './templates/account_menu'
  events:
    'click #addItem': -> app.execute 'show:entity:search'
    'click #name': -> app.execute 'show:inventory:user', app.user
    'click #edit': -> app.execute 'show:user:edit'
    'click #logout': -> app.execute 'persona:logout'

  serializeData: ->
    attrs =
      search:
        nameBase: 'search'
        field:
          placeholder: _.i18n 'Add or search a book'
        button:
          icon: 'search'
          classes: 'secondary'

    if _.isMobile then attrs.scanner = scanner.url
    return _.extend attrs, @model.toJSON()

  initialize: ->
    # /!\ CommonEl custom Regions implies side effects
    # probably limited to the region management functionalities:
    # CommonEl regions insert their views AFTER the attached el
    @addRegion 'requests', CommonEl.extend {el: '#before-requests'}
    @addRegion 'notifs', CommonEl.extend {el: '#before-notifications'}

  onShow: ->
    app.execute 'foundation:reload'
    @showRequests()
    @showNotifications()

  showRequests: ->
    view = new RequestsList {collection: app.users.othersRequests}
    @requests.show view

  showNotifications: ->
    view = new NotificationsList {collection: app.user.notifications}
    @notifs.show view