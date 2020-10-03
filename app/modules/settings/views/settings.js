import { I18n } from 'modules/user/lib/i18n'
const views = {
  profile: require('./profile_settings'),
  account: require('./account_settings'),
  notifications: require('./notifications_settings'),
  data: require('./data_settings')
}

export default Marionette.LayoutView.extend({
  id: 'settings',
  template: require('./templates/settings.hbs'),
  regions: {
    tabsContent: '.custom-tabs-content'
  },

  ui: {
    tabsTitles: '.custom-tabs-titles',
    profileTitle: '#profile',
    accountTitle: '#account',
    notificationsTitle: '#notifications',
    dataTitle: '#data'
  },

  onShow () {
    return app.request('wait:for', 'user')
    .then(this.showTab.bind(this, this.options.tab))
  },

  events: {
    'click #profile': 'showProfileSettings',
    'click #account': 'showAccountSettings',
    'click #notifications': 'showNotificationsSettings',
    'click #data': 'showDataSettings'
  },

  showTab (tab) {
    const View = views[tab]
    this.tabsContent.show(new View({ model: this.model }))
    return this.tabUpdate(tab)
  },

  tabUpdate (tab) {
    this.setActiveTab(tab)

    const tabLabel = I18n(tab)
    const settings = I18n('settings')

    return app.navigate(`settings/${tab}`,
      { metadata: { title: `${tabLabel} - ${settings}` } })
  },

  setActiveTab (name) {
    const tab = `${name}Title`
    this.ui.tabsTitles.find('a').removeClass('active')
    return this.ui[tab].addClass('active')
  },

  showProfileSettings () { this.showTab('profile') },
  showAccountSettings () { this.showTab('account') },
  showNotificationsSettings () { this.showTab('notifications') },
  showDataSettings () { this.showTab('data') }
})
