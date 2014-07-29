module.exports = class AppLayout extends Backbone.Marionette.LayoutView
  template: require 'views/templates/app_layout'
  el: "body"

  regions:
    main: "main"
    accountMenu: "#accountMenu"
    modal: "#modalContent"

  events:
    'click': 'preventDefault'
    'click a.close': 'closeAlertBox'

  initialize: (e)->
    @render()

  ############ ERRORS ############
  closeAlertBox: (e)->
    e.preventDefault()
    console.log $(e.target)
    $(e.target).parent('div .alert-box').hide()

  preventDefault: (e)->
    e.preventDefault()
