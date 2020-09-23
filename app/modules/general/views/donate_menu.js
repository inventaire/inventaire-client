{ donate } = require 'lib/urls'

module.exports = Marionette.ItemView.extend
  template: require './templates/donate_menu'
  className: ->
    standalone = if @options.standalone then 'standalone' else ''
    return "donate-menu #{standalone}"

  initialize: ->
    { @standalone } = @options

  behaviors:
    General: {}

  onShow: -> unless @standalone then app.execute 'modal:open'

  serializeData: -> _.extend donate, { @standalone }
