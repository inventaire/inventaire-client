waitForCheck = require '../lib/wait_for_check'
documentLang = require '../lib/document_lang'
showViews = require '../lib/show_views'
TopBar = require './top_bar'
initModal = require '../lib/modal'
initFlashMessage = require '../lib/flash_message'
ConfirmationModal = require './confirmation_modal'
screen_ = require 'lib/screen'

module.exports = Marionette.LayoutView.extend
  template: require './templates/app_layout'

  el: '#app'

  regions:
    topBar: '#topBar'
    main: 'main'
    modal: '#modalContent'

  ui:
    topBar: '#topBar'
    flashMessage: '#flashMessage'

  events:
    'click .showEntityEdit': 'showEntityEdit'
    'click .showEntityCleanup': 'showEntityCleanup'

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
      'show:feedback:menu': @showFeedbackMenu
      'show:donate:menu': @showDonateMenu
      'ask:confirmation': @askConfirmation.bind(@)
      'history:back': (options)->
        # Go back only if going back means staying in the app
        if Backbone.history.last.length > 0 then window.history.back()
        else options?.fallback?()

    app.reqres.setHandlers
      'waitForCheck': waitForCheck
      'post:feedback': postFeedback

    documentLang @$el, app.user.lang

    initModal()
    initFlashMessage.call @
    # wait for the app to be initiated before listening to resize events
    # to avoid firing a meaningless event at initialization
    app.request('waitForNetwork').then initWindowResizeEvents

    $('body').on 'click', app.vent.Trigger('body:click')

  # /!\ app_layout is never 'show'n so onShow never gets fired
  # but it gets rendered
  onRender: ->
    @topBar.show new TopBar

  askConfirmation: (options)-> @modal.show new ConfirmationModal(options)

initWindowResizeEvents = ->
  previousScreenMode = screen_.isSmall()
  resizeEnd = ->
    newScreenMode = screen_.isSmall()
    if newScreenMode isnt previousScreenMode
      previousScreenMode = newScreenMode
      app.vent.trigger 'screen:mode:change'

  resize = _.debounce resizeEnd, 150
  $(window).resize resize

# params = { subject, message, uris, context, unknownUser }
postFeedback = (params)->
  params.context ?= {}
  params.context.location =document.location.pathname + document.location.search
  _.log params, 'posting feedback'
  _.preq.post app.API.feedback, params
