zxing = require 'modules/inventory/lib/scanner/zxing'
embedded_ = require 'modules/inventory/lib/scanner/embedded'
zxingLocalSetting = window.localStorageBoolApi 'use-zxing-scanner'

module.exports = Marionette.ItemView.extend
  className: 'scan'
  template: require './templates/scan'
  initialize: -> prepareEmbeddedScanner()
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
  startEmbeddedScanner: -> app.execute 'show:scanner:embedded'

  toggleZxing: (e)->
    { checked } = e.currentTarget

    # in case zxing was selected when the view was initalized
    # thus preventing to fire embedded_.prepare
    unless checked then prepareEmbeddedScanner false

    zxingLocalSetting.set checked
    # wait for the end of the toggle animation
    # keep in sync with app/modules/general/scss/_toggler.scss
    setTimeout @render.bind(@), 400

prepareEmbeddedScanner = (useZxing)->
  useZxing ?= zxingLocalSetting.get()
  if window.hasVideoInput and not useZxing
    embedded_.prepare()
