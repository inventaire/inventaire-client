zxing = require 'modules/inventory/lib/scanner/zxing'
embeddedScanner = require 'modules/inventory/lib/scanner/embedded'

module.exports = Marionette.ItemView.extend
  className: 'scan'
  template: require './templates/scan'
  serializeData: ->
    hasVideoInput: window.hasVideoInput
    zxing: zxing
    useZxing:
      id: 'toggleZxing'
      label: 'use_zxing_application'
      checked: zxingLocalSetting.get()
      inverted: false

  events:
    'click #embeddedScanner': 'startEmbeddedScanner'
    # should open the href url
    'click #zxingScanner': 'setAddModeScanZxing'
    'change .toggler-input': 'toggleZxing'

  setAddModeScanZxing: -> app.execute 'last:add:mode:set', 'scan:zxing'
  startEmbeddedScanner: -> embeddedScanner @$el

  toggleZxing: (e)->
    { checked } = e.currentTarget
    zxingLocalSetting.set checked
    # wait for the end of the toggle animation
    # keep in sync with app/modules/general/scss/_toggler.scss
    setTimeout @render.bind(@), 400

zxingLocalSetting = window.localStorageBoolApi 'use-zxing-scanner'
