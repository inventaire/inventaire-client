NotLoggedMenu = require 'views/not_logged_menu'

module.exports = class Welcome extends Backbone.Marionette.LayoutView
  id: 'welcome'
  template: require 'views/templates/welcome'
  regions:
    loginButtons: '#loginButtons'

  onShow: ->
    buttons = new NotLoggedMenu
    @loginButtons.show buttons
    @$el.find('li').addClass('button')