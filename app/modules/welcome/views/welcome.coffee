NotLoggedMenu = require 'modules/general/views/menu/not_logged_menu'
loginPlugin = require 'modules/general/plugins/login'
showLastPublicItems = require '../lib/show_last_public_items'
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
    unless app.user.loggedIn or _.smallScreen()
      app.vent.trigger 'top:bar:hide'
      @showTopBarOnceLandingScreenIsOutOfView()

    @waitForMention
    .then @showMentions.bind(@)

  showTopBarOnceLandingScreenIsOutOfView: ->
    @ui.landingScreen.on 'inview', (e, inview)=>
      if not inview
        app.vent.trigger 'top:bar:show'
        @ui.landingScreen.off 'inview'

  showPublicItems: ->
    showLastPublicItems
      region: @previewColumns
      limit: 15
      allowMore: false
      assertImage: true
    .catch @hidePublicItems.bind(@)
    .catch _.Error('hidePublicItems err')

    @triggerMethod 'child:view:ready'

  onDestroy: ->
    app.vent.trigger 'top:bar:show'
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
