module.exports = class Welcome extends Backbone.Marionette.LayoutView
  id: 'welcome'
  template: require 'views/templates/welcome'
  regions:
    loginButtons: '#loginButtons'

  onShow: ->
    buttons = new app.View.NotLoggedMenu
    @loginButtons.show buttons
    @$el.find('li').addClass('button')