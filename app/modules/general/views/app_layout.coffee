moveCaretToEnd = require '../lib/move_caret_to_end'
waitForCheck = require '../lib/wait_for_check'
enterClick = require '../lib/enter_click'
documentLang = require '../lib/document_lang'
showViews = require '../lib/show_views'
IconNav = require './icon_nav'
initIconNavHandlers = require '../lib/icon_nav'

module.exports = AppLayout = Backbone.Marionette.LayoutView.extend
  template: require './templates/app_layout'

  el: '#app'

  regions:
    iconNav: '#iconNav'
    main: 'main'
    accountMenu: '#accountMenu'
    modal: '#modalContent'
    joyride: '#joyride'

  events:
    'submit form': (e)-> e.preventDefault()
    'click #home, #inventorySections, .showHome': -> app.execute 'show:home'
    'click .showWelcome': -> app.execute 'show:welcome'
    'click .showLogin': -> app.execute 'show:login'
    'click .showInventory': -> app.execute 'show:inventory'
    'click .showFeedbacksMenu': 'showFeedbacksMenu'
    'keyup .enterClick': enterClick
    'click a.back': -> window.history.back()
    'click a#searchButton': 'search'
    'click a.wd-Q, a.showEntity': 'showEntity'
    'click .copyLink': 'copyLink'
    'click .toggle-topbar': 'toggleSideNav'
    'focus textarea': moveCaretToEnd

  behaviors:
    PreventDefault: {}

  initialize: (e)->
    _.extend @, showViews

    @render()
    app.vent.trigger 'layout:ready'
    app.commands.setHandlers
      'show:loader': @showLoader
      'main:fadeIn': -> app.layout.main.$el.hide().fadeIn(200)
      'bg:book:toggle': -> $('main').toggleClass('book-bg')
      'current:username:set': @setCurrentUsername
      'current:username:hide': @hideCurrentUsername
      'show:joyride:welcome:tour': @showJoyrideWelcomeTour.bind(@)

    app.reqres.setHandlers
      'waitForCheck': waitForCheck

    # needed by search engines
    # or to make by-language css rules (with :lang)
    documentLang.keepBodyLangUpdated.call(@)

    initIconNavHandlers.call(@)

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
      back_text: _.i18n 'back'
      is_hover: false

  search: ->
    query = $('input#searchField').val()
    _.log query, 'search query'
    app.execute 'search:global', query

  setCurrentUsername: (username)->
    $('#currentUsername').text(username)
    $('#currentUser').slideDown()

  hideCurrentUsername: ->
    $('#currentUser').hide()

  toggleSideNav: -> $('#sideNav').toggleClass('hide-for-small-only')
