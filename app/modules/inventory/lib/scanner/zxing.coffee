{ buildPath } = require 'lib/location'

# see doc: https://github.com/zxing/zxing/wiki/Scanning-From-Web-Pages
callback = buildPath "#{window.location.root}/entity/isbn:{CODE}/add",
  SCAN_FORMATS: 'UPC_A,EAN_13'
  raw: '{RAWCODE}'

url = buildPath 'zxing://scan/', { ret: _.fixedEncodeURIComponent(callback) }

module.exports =
  url: url
  apps:
    android: [{
      url: 'https://play.google.com/store/apps/details?id=com.google.zxing.client.android'
      name: 'Barcode Scanner for Android'
      platform: 'android'
      icon: 'barcode-scanner'
    }]
