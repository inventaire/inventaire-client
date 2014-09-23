module.exports = class AppLayout extends Backbone.Marionette.LayoutView
  template: require 'views/templates/app_layout'
  behaviors:
    PreventDefault: {}

  el: 'body'

  regions:
    main: 'main'
    accountMenu: '#accountMenu'
    modal: '#modalContent'

  events:
    'click #home': 'showHome'
    'keyup .enterClick': 'enterClick'
    'click a.back': -> window.history.back()

  initialize: (e)->
    @render()
    app.vent.trigger 'layout:ready'
    app.commands.setHandlers
      'show:home': @showHome
      'show:loader': @showLoader
      'show:403': @show403
      'show:404': @show404
      'main:fadeIn': -> app.layout.main.$el.hide().fadeIn(200)

  showLoader: (region)->
    region ||= app.layout.main
    region.show new app.View.Behaviors.Loader

  showHome: ->
    _.log 'show:home'
    if app.user.loggedIn
      app.execute 'show:inventory:personal'
      app.execute 'main:fadeIn'
    else
      app.execute 'show:welcome'
      app.execute 'main:fadeIn'

  enterClick: (e)->
    if e.keyCode is 13 && $(e.currentTarget).val().length > 0
      row = $(e.currentTarget).parents('.row')[0]
      $(row).find('.button').trigger 'click'
      _.log 'ui: enter-click'

  show403: ->
    showError
      code: 403
      message: _.i18n 'Forbidden'

  show404: ->
    showError
      code: 404
      message: _.i18n 'Not Found'

showError = (options)->
  app.layout.main.show new app.View.Error options