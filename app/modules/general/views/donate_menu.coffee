{ bitcoin, gratipay } = require 'lib/urls'

module.exports = Marionette.ItemView.extend
  template: require './templates/donate_menu'

  className: ->
    standalone = if @options.standalone then 'standalone' else ''
    _.log standalone, 'standalone'
    return "donate-menu #{standalone}"

  behaviors:
    General: {}

  onShow: ->
    unless @options.standalone
      app.execute 'modal:open'

  serializeData: ->
    bitcoin: bitcoin
    standalone: @options.standalone
