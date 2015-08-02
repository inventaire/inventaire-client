NotLoggedMenu = require 'modules/general/views/menu/not_logged_menu'
newsletterSusbscribe = require './newsletter_susbscribe'
# required by newsletterSusbscribe
behaviorsPlugin = require 'modules/general/plugins/behaviors'

module.exports = Marionette.LayoutView.extend
  id: 'welcome'
  template: require './templates/welcome'
  regions:
    previewColumns: '#previewColumns'

  initialize: ->
    # importing loggin buttons events
    @events = _.extend @events, NotLoggedMenu::events
    _.extend @, newsletterSusbscribe, behaviorsPlugin

  events:
    'click #subscribeButton': 'subscribeToNewsletter'

  behaviors:
    AlertBox: {}
    Loading: {}
    SuccessCheck: {}

  serializeData: ->
    loggedIn: app.user.loggedIn
    subscribe: @subscribeData()

  ui:
    topBarTrigger: '#middle-three'
    email: '#subscribeField'
    thanks: '#thanks'

  onShow: ->
    @loadPublicItems()
    unless app.user.loggedIn
      @hideTopBar()
      @ui.topBarTrigger.once 'inview', @showTopBar
      @hideFeedbackButton()


  onDestroy: ->
    @showTopBar()
    @showFeedbackButton()

  loadPublicItems: ->
    _.preq.get app.API.items.lastPublicItems
    .catch _.preq.catch404
    .then @displayPublicItems.bind(@)
    .catch @hidePublicItems.bind(@)
    .catch (err)-> _.error err, 'hidePublicItems err'

  displayPublicItems: (res)->
    unless res?.items?.length > 0 then return @hidePublicItems()

    app.users.public.add res.users

    items = new app.Collection.Items
    items.add res.items

    itemsColumns = new app.View.Items.List
      collection: items
    @previewColumns.show itemsColumns

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
