AccountMenuTemplate = require 'views/templates/account_menu'

module.exports = AccountMenuView = Backbone.View.extend
  tagName: 'li'
  className: 'has-dropdown'
  template: AccountMenuTemplate
  initialize: ->
    @render()
    $('#menu').append @$el

  render: ->
    @$el.html @template(@model.attributes)
    @$el.foundation()
    return @

  # events: