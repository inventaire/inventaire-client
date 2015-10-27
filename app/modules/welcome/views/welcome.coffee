NotLoggedMenu = require 'modules/general/views/menu/not_logged_menu'
newsletterSusbscribe = require './newsletter_susbscribe'
# required by newsletterSusbscribe
behaviorsPlugin = require 'modules/general/plugins/behaviors'
loginPlugin = require 'modules/general/plugins/login'
showLastPublicItems = require '../lib/show_last_public_items'
urls = require 'lib/urls'

module.exports = Marionette.LayoutView.extend
  id: 'welcome'
  template: require './templates/welcome'
  regions:
    previewColumns: '#previewColumns'

  initialize: ->
    loginPlugin.call @
    _.extend @, newsletterSusbscribe, behaviorsPlugin

  events:
    'click #subscribeButton': 'subscribeToNewsletter'
    'click .toggleMission': 'toggleMission'

  behaviors:
    AlertBox: {}
    Loading: {}
    SuccessCheck: {}

  serializeData: ->
    loggedIn: app.user.loggedIn
    subscribe: @subscribeData()
    urls: urls

  ui:
    topBarTrigger: '#middle-three'
    email: '#subscribeField'
    thanks: '#thanks'
    missions: 'ul.mission li'
    missionsTogglers: '.toggleMission .fa'

  onShow: ->
    @showPublicItems()
    unless app.user.loggedIn
      @hideTopBar()
      @ui.topBarTrigger.once 'inview', @showTopBar
      @hideFeedbackButton()

  showPublicItems: ->
    showLastPublicItems @previewColumns
    .catch @hidePublicItems.bind(@)
    .catch _.Error('hidePublicItems err')

  onDestroy: ->
    @showTopBar()
    @showFeedbackButton()

  hidePublicItems: (err)->
    $('#lastPublicBooks').hide()
    if err? then throw err

  hideTopBar: ->
    $('.top-bar').hide()
    $('main').addClass('no-topbar')
  showTopBar: ->
    $('.top-bar').slideDown()
    $('main').removeClass('no-topbar')

  hideFeedbackButton: -> $('#feedback').hide()
  showFeedbackButton: -> $('#feedback').fadeIn()
  toggleMission: ->
    @ui.missions.slideToggle()
    @ui.missionsTogglers.toggle()
