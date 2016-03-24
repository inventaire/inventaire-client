embeddedScanner = require 'modules/inventory/lib/scanner/embedded'

module.exports = Marionette.ItemView.extend
  template: require './templates/embedded_scanner'
  className: 'embedded'
  events:
    'click .close': 'close'

  onShow: ->
    app.execute 'last:add:mode:set', 'scan:embedded'

    @previousRoute = _.currentRoute()
    # navigate to a different route so that hitting back
    # looks like escaping the embedded scanner
    app.navigate 'add/scan/embedded'

    @listenTo app.vent, 'route:change', @stop.bind(@)

    @scanner = embeddedScanner '.container'
      .then _.Log('embedded scanner isbn')
      .then (isbn)=>
        @revertRoute()
        app.execute 'show:entity:add', "isbn:#{isbn}"
      .catch _.Error('embedded scanner err')

  revertRoute: ->
    # remove the add/scan/embedded from the history
    app.navigateReplace @previousRoute

  close: ->
    @revertRoute()
    @stop()

  stop: ->
    # reverting route isn't needed when stopping is due to a route event
    @scanner.cancel()
    @destroy()
