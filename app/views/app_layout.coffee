module.exports = class AppLayout extends Backbone.Marionette.LayoutView
  template: require 'views/templates/app_layout'
  el: "body"

  regions:
    main: "main"
    accountMenu: "#accountMenu"
    modal: "#modalContent"

  events:
    'click': 'preventDefault'
    'keyup .enterClick': 'enterClick'

  initialize: (e)->
    @render()

  preventDefault: (e)->
    e.preventDefault()

  enterClick: (e)->
    _.log 'enterClick!'
    if e.keyCode is 13 && $(e.currentTarget).val().length > 0
      $(e.currentTarget).parents('.row').find('.button').trigger 'click'