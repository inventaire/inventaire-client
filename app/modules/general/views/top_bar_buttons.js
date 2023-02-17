import { viewportIsSmall } from '#lib/screen'
import { clickCommand } from '#lib/utils'
import topBarButtonsTemplate from './templates/top_bar_buttons.hbs'

export default Marionette.View.extend({
  template: topBarButtonsTemplate,

  className: 'innerTopBarButtons',

  initialize () {
    this.listenTo(app.vent, {
      'screen:mode:change': this.lazyRender.bind(this),
      'transactions:unread:change': this.lazyRender.bind(this),
      'network:requests:update': this.lazyRender.bind(this)
    })

    // Re-render once relations and groups are populated to display network counters
    Promise.all([
      app.request('wait:for', 'relations'),
      app.request('wait:for', 'groups')
    ])
    .then(this.lazyRender.bind(this))
  },

  serializeData () {
    return {
      smallScreen: viewportIsSmall(),
      exchangesUpdates: app.request('transactions:unread:count'),
      notificationsUpdates: this.getNotificationsCount(),
      username: app.user.get('username'),
      userPicture: app.user.get('picture'),
      userPathname: app.user.get('pathname')
    }
  },

  events: {
    'click #exchangesIconButton': clickCommand('show:transactions'),
    'click #notificationsIconButton': clickCommand('show:notifications'),

    'click .showMainUser': clickCommand('show:inventory:main:user'),
    'click .showSettings': clickCommand('show:settings'),
    'click .showInfo': clickCommand('show:welcome'),
    'click .showFeedbackMenu': clickCommand('show:feedback:menu'),
    'click .logout' () { app.execute('logout') }
  },

  getNotificationsCount () {
    const unreadNotifications = app.request('notifications:unread:count')
    const networkRequestsCount = app.request('get:network:invitations:count')
    return unreadNotifications + networkRequestsCount
  }
})
