module.exports = class AppLayout extends Backbone.Marionette.LayoutView
  template: require './templates/app_layout'

  el: 'body'

  regions:
    main: 'main'
    accountMenu: '#accountMenu'
    modal: '#modalContent'

  events:
    'click a': 'unpreventDefault'
    'click #home, #inventorySections': -> app.execute 'show:home'
    'keyup .enterClick': 'enterClick'
    'click a.back': -> window.history.back()
    'click a#searchButton': 'search'
    'focus #searchField': 'maximizeSearchField'
    'focusout #searchField': 'unmaximizeIfNotAtSearch'
    'click a.wd-Q, a.showEntity': 'showEntity'
    'click .toggle-topbar': 'toggleSideNav'

  initialize: (e)->
    @render()
    app.vent.trigger 'layout:ready'
    app.commands.setHandlers
      'show:loader': @showLoader
      'main:fadeIn': -> app.layout.main.$el.hide().fadeIn(200)
      'search:field:maximize': @maximizeSearchField
      'search:field:unmaximize': @unmaximizeSearchField
      'bg:book:toggle': -> $('main').toggleClass('book-bg')
      'current:username:set': @setCurrentUsername
      'current:username:hide': @hideCurrentUsername

    app.reqres.setHandlers
      'waitForCheck': @waitForCheck
      'ifOnline': @ifOnline

  serializeData: ->
    data =
      topbar:
        options:
          sticky_on: 'large'
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
      row = $(e.currentTarget).parents('.row')[0]
      $(row).find('.button').trigger 'click'
      _.log 'ui: enter-click'

  waitForCheck: (options)->
    _.log options, 'waitForCheck options'
    # $selector or selector MUST be provided
    if options.selector? then $selector = $(options.selector)
    else $selector = options.$selector
    $selector.trigger('loading')

    # action or promise MUST be provided
    if options.action? then promise = options.action()
    else promise = options.promise

    # success and/or error handlers CAN be provided
    promise
    .then (res)-> $selector.trigger('check', options.success)
    .fail (err)-> $selector.trigger('fail', options.error)

    return promise

  search: ->
    query = $('input#searchField').val()
    _.log query, 'search query'
    app.execute 'search:global', query

  maximizeSearchField: -> $('#searchGroup').addClass('maximized')
  unmaximizeSearchField: -> $('#searchGroup').removeClass('maximized')
  unmaximizeIfNotAtSearch: ->
    @unmaximizeSearchField()  unless _.currentLocationMatch '/search'

  showEntity: (e)->
    href = e.target.href
    data = href.split('/entity/').last()
    [uri, label] = data.split '/'
    app.execute 'show:entity', uri, label

  unpreventDefault: (e)->
    # largely inspired by
    # https://github.com/jmeas/backbone.intercept/blob/master/src/backbone.intercept.js

    # Only intercept left-clicks
    return  if e.which isnt 1

    $link = $(e.currentTarget)
    # Get the href; stop processing if there isn't one
    href = $link.attr("href")
    return  unless href

    # Return if the URL is absolute, or if the protocol is mailto or javascript
    return  if /^#|javascript:|mailto:|(?:\w+:)?\/\//.test(href)

    # If we haven't been stopped yet, then we prevent the default action
    e.preventDefault()

  ifOnline: (cb, context, args...)->
    _.ping()
      .then -> cb.apply context, args
      .fail ->
        app.execute 'show:error',
          message: _.i18n "can't reach the server"

  setCurrentUsername: (username)->
    $('#currentUsername').text(username)
    $('#currentUser').slideDown()

  hideCurrentUsername: ->
    $('#currentUser').hide()

  toggleSideNav: -> $('#sideNav').toggleClass('hide-for-small-only')