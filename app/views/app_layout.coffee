module.exports = class AppLayout extends Backbone.Marionette.LayoutView
  template: require 'views/templates/app_layout'
  el: "body"

  regions:
    main: "main"
    accountMenu: "#accountMenu"
    modal: "#modalContent"

  events:
    'click': 'triggerPreventDefault'
    'keyup .enterClick': 'enterClick'

  initialize: (e)->
    @render()
    app.vent.trigger 'layout:ready'

  triggerPreventDefault: (e)->
    unless _.hasValue(e.target.className.split(' '), 'default')
      e.preventDefault()

  enterClick: (e)->
    if e.keyCode is 13 && $(e.currentTarget).val().length > 0
      $(e.currentTarget).parents('.row').find('.button').trigger 'click'