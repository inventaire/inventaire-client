import log_ from 'lib/loggers'
import preq from 'lib/preq'
import showPaginatedItems from '../lib/show_paginated_items'
import * as urls from 'lib/urls'
import Mentions from './mentions'
import welcomeTemplate from './templates/welcome.hbs'
import '../scss/welcome.scss'

export default Marionette.LayoutView.extend({
  id: 'welcome',
  template: welcomeTemplate,
  regions: {
    previewColumns: '#previewColumns',
    mentions: '#mentions'
  },

  initialize () {
    this.waitForMention = getMentionsData()
  },

  events: {
    'click .toggleMission': 'toggleMission'
  },

  behaviors: {
    AlertBox: {},
    DeepLinks: {},
    Loading: {},
    SuccessCheck: {}
  },

  serializeData () {
    return {
      loggedIn: app.user.loggedIn,
      urls,
      needNameExplanation: app.user.lang !== 'fr'
    }
  },

  ui: {
    thanks: '#thanks',
    missions: 'ul.mission li',
    missionsTogglers: '.toggleMission .fa',
    landingScreen: '#landingScreen'
  },

  async onShow () {
    this.showPublicItems()

    const data = await this.waitForMention
    if (this.isIntact()) this.showMentions(data)
  },

  showPublicItems () {
    showPaginatedItems({
      request: 'items:getRecentPublic',
      region: this.previewColumns,
      allowMore: false,
      limit: 15,
      lang: app.user.lang,
      assertImage: true
    })
    .catch(this.hidePublicItems.bind(this))
    .catch(log_.Error('hidePublicItems err'))

    this.triggerMethod('child:view:ready')
  },

  hidePublicItems (err) {
    $('#lastPublicBooks').hide()
    if (err != null) throw err
  },

  toggleMission () {
    this.ui.missions.slideToggle()
    this.ui.missionsTogglers.toggle()
  },

  showMentions (data) {
    this.triggerMethod('child:view:ready')
    this.mentions.show(new Mentions({ data }))
  }
})

// no need to fetch mentions data more than once per session
const mentionsData = null
const getMentionsData = function () {
  if (mentionsData != null) {
    return Promise.resolve(mentionsData)
  } else {
    return preq.get(app.API.json('mentions'))
  }
}
