embeddedScanner = require 'modules/inventory/lib/scanner/embedded'

module.exports = Marionette.ItemView.extend
  template: require './templates/embedded_scanner'
  className: 'embedded'
  events:
    'click .close': 'close'

  onShow: ->
    app.execute 'last:add:mode:set', 'scan:embedded'

    @listenToOnce app.vent, 'route:change', @stop.bind(@)

    @scanner = embeddedScanner '.container'
      .then _.Log('embedded scanner isbn')
      .then (isbn)-> app.execute 'show:entity:add', "isbn:#{isbn}"
      .catch _.Error('embedded scanner err')

  close: ->
    @stop()
    # come back to the previous view
    window.history.back()

  stop: ->
    # Cancelling the promise to let the opportunity to Quagga to stop properly
    # and avoid having a promise unfulfilled.
    @scanner.cancel()
    @destroy()
    # Reverting route isn't needed when stopping is due to a route event.
