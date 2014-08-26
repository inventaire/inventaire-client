module.exports = class AppLayout extends Backbone.Marionette.LayoutView
  template: require 'views/templates/app_layout'
  el: 'body'

  regions:
    main: 'main'
    accountMenu: '#accountMenu'
    modal: '#modalContent'

  events:
    'click #home': 'showHome'
    'click a': 'triggerPreventDefault'
    'keyup .enterClick': 'enterClick'

  initialize: (e)->
    @render()
    app.vent.trigger 'layout:ready'
    app.commands.setHandlers
      'show:home': @showHome
      'main:fadeIn': -> app.layout.main.$el.hide().fadeIn(200)

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