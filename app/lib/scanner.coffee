module.exports =
  url: (->
    # https://github.com/zxing/zxing/wiki/Scanning-From-Web-Pages
    callback = _.buildPath "#{window.location.root}/entity/isbn:{CODE}/add",
      SCAN_FORMATS: 'UPC_A,EAN_13'
      raw: '{RAWCODE}'

    encodedCallback = encodeURIComponent(callback)

    url = _.buildPath "zxing://scan/",
    # url = _.buildPath "http://zxing.appspot.com/scan",
      ret: encodedCallback

    return url
    )()