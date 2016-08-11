waitForCheck = require '../lib/wait_for_check'
documentLang = require '../lib/document_lang'
showViews = require '../lib/show_views'
IconNav = require './icon_nav'
initIconNavHandlers = require '../lib/icon_nav'
initDynamicBackground = require '../lib/dynamic_background'
initHeadMetadataCommands = require '../lib/head_metadata'

module.exports = Marionette.LayoutView.extend
  template: require './templates/app_layout'

  el: '#app'

  regions:
    iconNav: '#iconNav'
    main: 'main'
    accountMenu: '#accountMenu'
    modal: '#modalContent'
    joyride: '#joyride'

  ui:
    bg: '#bg'
    topBar: '#topBar'
    lateralButtons: '#lateralButtons'

  events:
    'click .showDonateMenu': 'showDonateMenu'
    'click .showFeedbackMenu': 'showFeedbackMenu'
    'click a.entity-value, a.showEntity': 'showEntity'
    'click .shareLink': 'shareLink'

  behaviors:
    General: {}
    PreventDefault: {}

  initialize: (e)->
    _.extend @, showViews

    @render()
    app.commands.setHandlers
      'show:loader': @showLoader
      'main:fadeIn': -> app.layout.main.$el.hide().fadeIn(200)
      'current:username:set': @setCurrentUsername
      'current:username:hide': @hideCurrentUsername
      'show:joyride:welcome:tour': @showJoyrideWelcomeTour.bind(@)
      'show:feedback:menu': @showFeedbackMenu

    app.reqres.setHandlers
      'waitForCheck': waitForCheck

    documentLang @$el, app.user.lang
    initHeadMetadataCommands()

    initIconNavHandlers.call(@)
    initDynamicBackground.call(@)
    # wait for the app to be initiated before listening to resize events
    # to avoid firing a meaningless event at initialization
    app.request('waitForData').then initWindowResizeEvents

    app.vent.on
      'top:bar:show': @showTopBar.bind(@)
      'top:bar:hide': @hideTopBar.bind(@)
      'lateral:buttons:show': @ui.lateralButtons.show.bind(@ui.lateralButtons)
      'lateral:buttons:hide': @ui.lateralButtons.hide.bind(@ui.lateralButtons)

  serializeData: ->
    topbar: @topBarData()

  # /!\ app_layout is never 'show'n so onShow never gets fired
  # but it gets rendered
  onRender: ->
    # render icon and let icon handlers show or hide it
    @iconNav.show new IconNav

  topBarData: ->
    options:
      custom_back_text: true
      back_text: _.icon('caret-left') + ' ' + _.i18n('back')
      is_hover: false

  setCurrentUsername: (username)->
    $('#currentUsername').text(username)
    $('#currentUser').slideDown()

  hideCurrentUsername: ->
    $('#currentUser').hide()

  showTopBar: ->
    @main.$el.removeClass 'no-topbar'
    @ui.topBar.slideDown()

  hideTopBar: ->
    @main.$el.addClass 'no-topbar'
    @ui.topBar.hide()

initWindowResizeEvents = ->
  previousScreenMode = _.smallScreen()
  resizeEnd = ->
    newScreenMode = _.smallScreen()
    if newScreenMode isnt previousScreenMode
      previousScreenMode = newScreenMode
      app.vent.trigger 'screen:mode:change'

  resize = _.debounce resizeEnd, 150
  $(window).resize resize
