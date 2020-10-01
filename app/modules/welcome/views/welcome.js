import showPaginatedItems from '../lib/show_paginated_items'
import urls from 'lib/urls'
import Mentions from './mentions'

export default Marionette.LayoutView.extend({
  id: 'welcome',
  template: require('./templates/welcome'),
  regions: {
    previewColumns: '#previewColumns',
    mentions: '#mentions'
  },

  initialize () {
    return this.waitForMention = getMentionsData()
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

  onShow () {
    this.showPublicItems()

    return this.waitForMention
    .then(this.ifViewIsIntact('showMentions'))
  },

  showPublicItems () {
    showPaginatedItems({
      request: 'items:getRecentPublic',
      region: this.previewColumns,
      allowMore: false,
      limit: 15,
      lang: app.user.lang,
      assertImage: true
    }).catch(this.hidePublicItems.bind(this))
    .catch(_.Error('hidePublicItems err'))

    return this.triggerMethod('child:view:ready')
  },

  hidePublicItems (err) {
    $('#lastPublicBooks').hide()
    if (err != null) { throw err }
  },

  toggleMission () {
    this.ui.missions.slideToggle()
    return this.ui.missionsTogglers.toggle()
  },

  showMentions (data) {
    this.triggerMethod('child:view:ready')
    return this.mentions.show(new Mentions({ data }))
  }
})

// no need to fetch mentions data more than once per session
const mentionsData = null
const getMentionsData = function () {
  if (mentionsData != null) {
    return Promise.resolve(mentionsData)
  } else { return _.preq.get(app.API.json('mentions')) }
}
