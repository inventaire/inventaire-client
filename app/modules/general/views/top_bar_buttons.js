import screen_ from 'lib/screen';

export default Marionette.ItemView.extend({
  template: require('./templates/top_bar_buttons'),

  className: 'innerTopBarButtons',

  initialize() {

    this.listenTo(app.vent, {
      'screen:mode:change': this.lazyRender.bind(this),
      'transactions:unread:change': this.lazyRender.bind(this),
      'network:requests:update': this.lazyRender.bind(this)
    }
    );

    // Re-render once relations and groups are populated to display network counters
    return Promise.all([
      app.request('wait:for', 'relations'),
      app.request('wait:for', 'groups')
    ])
    .then(this.lazyRender.bind(this));
  },

  serializeData() {
    return {
      smallScreen: screen_.isSmall(),
      exchangesUpdates: app.request('transactions:unread:count'),
      notificationsUpdates: this.getNotificationsCount(),
      username: app.user.get('username'),
      userPicture: app.user.get('picture'),
      userPathname: app.user.get('pathname')
    };
  },

  events: {
    'click #exchangesIconButton': _.clickCommand('show:transactions'),
    'click #notificationsIconButton': _.clickCommand('show:notifications'),

    'click .showMainUser': _.clickCommand('show:inventory:main:user'),
    'click .showSettings': _.clickCommand('show:settings'),
    'click .showInfo': _.clickCommand('show:welcome'),
    'click .showFeedbackMenu': _.clickCommand('show:feedback:menu'),
    'click .logout'() { return app.execute('logout'); }
  },

  getNotificationsCount() {
    const unreadNotifications = app.request('notifications:unread:count');
    const networkRequestsCount = app.request('get:network:invitations:count');
    return unreadNotifications + networkRequestsCount;
  }
});
