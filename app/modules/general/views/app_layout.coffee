JoyrideWelcomeTour = require 'modules/welcome/views/joyride_welcome_tour'
FeedbacksMenu = require './feedbacks_menu'

module.exports = AppLayout = Backbone.Marionette.LayoutView.extend
  template: require './templates/app_layout'

  el: '#app'

  regions:
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
    'keyup .enterClick': 'enterClick'
    'click a.back': -> window.history.back()
    'click a#searchButton': 'search'
    'click a.wd-Q, a.showEntity': 'showEntity'
    'click .toggle-topbar': 'toggleSideNav'

  behaviors:
    PreventDefault: {}

  initialize: (e)->
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
      'waitForCheck': @waitForCheck

    # needed by search engines
    # or to make by-language css rules (with :lang)
    @keepBodyLangUpdated()

  serializeData: ->
    topbar: @topBarData()

  topBarData: ->
    options:
      custom_back_text: true
      back_text: _.i18n 'back'
      is_hover: false

  showLoader: (options)->
    [region, selector, title] = _.pickToArray options, ['region', 'selector', 'title']
    if region?
      region.Show new app.View.Behaviors.Loader, title
    else if selector?
      loader = new app.View.Behaviors.Loader
      $(selector).html loader.render()
      app.docTitle title  if title?
    else
      app.layout.main.Show new app.View.Behaviors.Loader, title

  enterClick: (e)->
    if e.keyCode is 13 and $(e.currentTarget).val().length > 0
      row = $(e.currentTarget).parents('form')[0]
      $target =  $(row).find('.button, .tiny-button')
      if $target.length > 0
        $target.trigger 'click'
        _.log 'ui: enter-click'
      else
        _.error('enterClick target not found')

  waitForCheck: (options)->
    {selector, $selector, action, promise, success, error} = options
    _.log options, 'waitForCheck options'
    # $selector or selector MUST be provided
    # if selector? then $selector = $(selector)
    $selector or= $(selector)
    $selector.trigger 'loading', {selector: selector}

    # action or promise MUST be provided
    if action? then promise = action()

    # success and/or error handlers CAN be provided
    promise
    .then (res)->
      $selector.trigger('check', success)
    .catch (err)->
      _.error err, 'waitForCheck err'
      $selector.trigger('fail', error)

    return promise

  search: ->
    query = $('input#searchField').val()
    _.log query, 'search query'
    app.execute 'search:global', query

  showEntity: (e)->
    href = e.target.href
    unless href?
      throw new Error "couldnt showEntity: href not found"

    unless _.isOpenedOutside(e)
      data = href.split('/entity/').last()
      [uri, label] = data.split '/'
      app.execute 'show:entity', uri, label

  setCurrentUsername: (username)->
    $('#currentUsername').text(username)
    $('#currentUser').slideDown()

  hideCurrentUsername: ->
    $('#currentUser').hide()

  toggleSideNav: -> $('#sideNav').toggleClass('hide-for-small-only')

  showJoyrideWelcomeTour: -> @joyride.show new JoyrideWelcomeTour

  keepBodyLangUpdated: ->
    @updateBodyLang app.request('i18n:current')
    @listenTo app.vent, 'i18n:set', @updateBodyLang.bind(@)

  updateBodyLang: (lang)-> @$el.attr 'lang', lang

  showFeedbacksMenu: ->
    app.layout.modal.show new FeedbacksMenu