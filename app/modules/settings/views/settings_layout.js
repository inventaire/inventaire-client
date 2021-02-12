import { I18n } from 'modules/user/lib/i18n'
import settingsTemplate from './templates/settings_layout.hbs'
import profile from './profile_settings'
import account from './account_settings'
import notifications from './notifications_settings'
import data from './data_settings'
import '../scss/settings_layout.scss'

const views = {
  profile,
  account,
  notifications,
  data,
}

export default Marionette.LayoutView.extend({
  id: 'settingsLayout',
  template: settingsTemplate,
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
    app.request('wait:for', 'user')
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

    app.navigate(`settings/${tab}`, {
      metadata: { title: `${tabLabel} - ${settings}` }
    })
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
