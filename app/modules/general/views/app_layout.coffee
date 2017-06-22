waitForCheck = require '../lib/wait_for_check'
documentLang = require '../lib/document_lang'
showViews = require '../lib/show_views'
TopBar = require './top_bar'
IconNav = require './icon_nav'
initIconNavHandlers = require '../lib/icon_nav'
initDynamicBackground = require '../lib/dynamic_background'
initModal = require '../lib/modal'
ConfirmationModal = require './confirmation_modal'

module.exports = Marionette.LayoutView.extend
  template: require './templates/app_layout'

  el: '#app'

  regions:
    topBar: '#topBar'
    iconNav: '#iconNav'
    main: 'main'
    modal: '#modalContent'
    joyride: '#joyride'

  ui:
    bg: '#bg'
    topBar: '#topBar'
    lateralButtons: '#lateralButtons'

  events:
    'click .showFeedbackMenu': 'showFeedbackMenu'
    'click .showEntityEdit': 'showEntityEdit'

  behaviors:
    General: {}
    PreventDefault: {}
    Dropdown: {}

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
      'show:donate:menu': @showDonateMenu
      'ask:confirmation': @askConfirmation.bind(@)

    app.reqres.setHandlers
      'waitForCheck': waitForCheck
      'post:feedback': postFeedback

    documentLang @$el, app.user.lang

    initIconNavHandlers.call(@)
    initDynamicBackground.call(@)
    initModal()
    # wait for the app to be initiated before listening to resize events
    # to avoid firing a meaningless event at initialization
    app.request('waitForNetwork').then initWindowResizeEvents

    app.vent.on
      # Use the class .hidden instead of .hide/.show methods
      # to let media query rules override it
      'lateral:buttons:show': => @ui.lateralButtons.removeClass 'hidden'
      'lateral:buttons:hide': => @ui.lateralButtons.addClass 'hidden'

    $('body').on 'click', app.vent.Trigger('body:click')

  # /!\ app_layout is never 'show'n so onShow never gets fired
  # but it gets rendered
  onRender: ->
    @topBar.show new TopBar
    # render icon and let icon handlers show or hide it
    @iconNav.show new IconNav

  setCurrentUsername: (username)->
    $('#currentUsername').text(username)
    $('#currentUser').slideDown()

  hideCurrentUsername: ->
    $('#currentUser').hide()

  askConfirmation: (options)-> @modal.show new ConfirmationModal(options)

initWindowResizeEvents = ->
  previousScreenMode = _.smallScreen()
  resizeEnd = ->
    newScreenMode = _.smallScreen()
    if newScreenMode isnt previousScreenMode
      previousScreenMode = newScreenMode
      app.vent.trigger 'screen:mode:change'

  resize = _.debounce resizeEnd, 150
  $(window).resize resize

# params = { subject, message, unknownUser }
postFeedback = (params)-> _.preq.post app.API.feedback, params
