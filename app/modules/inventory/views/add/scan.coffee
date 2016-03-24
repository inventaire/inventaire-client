zxing = require 'modules/inventory/lib/scanner/zxing'
embedded = require 'modules/inventory/lib/scanner/embedded'

module.exports = Marionette.ItemView.extend
  className: 'scan'
  template: require './templates/scan'
  serializeData: ->
    hasVideoInput: window.hasVideoInput
    zxing: zxing
    useZxing:
      id: 'toggleZxing'
      label: 'use_zxing_application'
      checked: getZxingSetting()
      inverted: false

  events:
    'click #embeddedScanner': 'startEmbeddedScanner'
    # should open the href url
    'click #zxingScanner': 'setAddModeScan'
    'change .toggler-input': 'toggleZxing'

  setAddModeScan: -> app.execute 'last:add:mode:set', 'scan'

  startEmbeddedScanner: ->
    @setAddModeScan()
    embedded()
    .then _.Log('embedded scanner isbn')
    .then (isbn)-> app.execute 'show:entity:add', "isbn:#{isbn}"
    .catch _.Error('embedded scanner err')

  toggleZxing: (e)->
    { checked } = e.currentTarget
    setZxingSetting checked
    # wait for the end of the toggle animation
    # keep in sync with app/modules/general/scss/_toggler.scss
    setTimeout @render.bind(@), 400

zxingSettingKey = 'use-zxing-scanner'
getZxingSetting = -> localStorageProxy.getItem(zxingSettingKey) is 'true'
setZxingSetting = (bool)-> localStorageProxy.setItem zxingSettingKey, bool
