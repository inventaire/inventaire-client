{ banner } = require('lib/urls').images

module.exports = Marionette.ItemView.extend
  template: require './templates/call_to_connection'
  onShow: -> app.execute 'modal:open'
  serializeData: ->
    _.extend @options,
      banner: banner

  events:
    # login buttons events are handled from the login plugin
    # but we still need to close the modal from here
    'click a': -> app.execute 'modal:close'
