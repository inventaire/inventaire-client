module.exports = class ScannerButton extends Backbone.Marionette.ItemView
  template: require 'views/items/form/templates/scanner'

  serializeData: ->
    # https://github.com/zxing/zxing/wiki/Scanning-From-Web-Pages
    callback = _.buildPath "http://192.168.1.49:3008/entity/isbn:{CODE}",
      SCAN_FORMATS: 'UPC_A,EAN_13'
      raw: '{RAWCODE}'

    encodedCallback = encodeURIComponent(callback)

    url = _.buildPath "zxing://scan/",
    # url = _.buildPath "http://zxing.appspot.com/scan",
      ret: encodedCallback

    _.log [url, encodedCallback], 'encodedCallback'

    return { url: url }
