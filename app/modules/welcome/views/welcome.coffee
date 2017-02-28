loginPlugin = require 'modules/general/plugins/login'
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
    loginPlugin.call @
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

  ui:
    thanks: '#thanks'
    missions: 'ul.mission li'
    missionsTogglers: '.toggleMission .fa'
    landingScreen: '#landingScreen'

  onShow: ->
    @showPublicItems()
    app.vent.trigger 'lateral:buttons:hide'

    @waitForMention
    .then @showMentions.bind(@)

  showPublicItems: ->
    showPaginatedItems
      request: 'items:getLastPublic'
      region: @previewColumns
      limit: 15
      allowMore: false
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
