showPaginatedItems = require '../lib/show_paginated_items'
urls = require 'lib/urls'
Mentions = require './mentions'

module.exports = Marionette.LayoutView.extend
  id: 'welcome'
  template: require './templates/welcome'
  regions:
    previewColumns: '#previewColumns'
    mentions: '#mentions'

  initialize: ->
    @waitForMention = getMentionsData()

  events:
    'click .toggleMission': 'toggleMission'

  behaviors:
    AlertBox: {}
    DeepLinks: {}
    Loading: {}
    SuccessCheck: {}

  serializeData: ->
    loggedIn: app.user.loggedIn
    urls: urls
    needNameExplanation: app.user.lang isnt 'fr'

  ui:
    thanks: '#thanks'
    missions: 'ul.mission li'
    missionsTogglers: '.toggleMission .fa'
    landingScreen: '#landingScreen'

  onShow: ->
    @showPublicItems()
    app.vent.trigger 'lateral:buttons:hide'

    @waitForMention
    .then @ifViewIsIntact('showMentions')

  showPublicItems: ->
    showPaginatedItems
      request: 'items:getRecentPublic'
      region: @previewColumns
      allowMore: false
      limit: 15
      lang: app.user.lang
      assertImage: true
    .catch @hidePublicItems.bind(@)
    .catch _.Error('hidePublicItems err')

    @triggerMethod 'child:view:ready'

  onDestroy: ->
    app.vent.trigger 'lateral:buttons:show'

  hidePublicItems: (err)->
    $('#lastPublicBooks').hide()
    if err? then throw err

  toggleMission: ->
    @ui.missions.slideToggle()
    @ui.missionsTogglers.toggle()

  showMentions: (data)->
    @triggerMethod 'child:view:ready'
    @mentions.show new Mentions({data: data})

# no need to fetch mentions data more than once per session
mentionsData = null
getMentionsData = ->
  if mentionsData? then _.preq.resolve mentionsData
  else _.preq.get app.API.json('mentions')
