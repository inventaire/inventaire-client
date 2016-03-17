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

  events:
    'click .showDonateMenu': 'showDonateMenu'
    'click .showFeedbackMenu': 'showFeedbackMenu'
    'click a.wd-Q, a.showEntity': 'showEntity'
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

    # needed by search engines
    # or to make by-language css rules (with :lang)
    documentLang.keepBodyLangUpdated.call(@)
    documentLang.keepHeadAlternateLangsUpdated.call(@)
    documentLang.updateOgLocalAlternates()
    initHeadMetadataCommands()

    initIconNavHandlers.call(@)
    initDynamicBackground.call(@)
    # wait for the app to be initiated before listening to resize events
    # to avoid firing a meaningless event at initialization
    app.request('waitForData').then initWindowResizeEvents

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


initWindowResizeEvents = ->
  previousScreenMode = _.smallScreen()
  resizeEnd = ->
    newScreenMode = _.smallScreen()
    if newScreenMode isnt previousScreenMode
      previousScreenMode = newScreenMode
      app.vent.trigger 'screen:mode:change'

  resize = _.debounce resizeEnd, 150
  $(window).resize resize
