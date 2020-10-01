// roughtly addressing the general case
if (location.hostname.match(/^(localhost|192\.168)/)) {
  window.env = 'dev'
} else {
  window.env = 'prod'
}

export default function () {
  if (window.env === 'dev') {
    const trueAlert = window.alert
    window.alert = function (obj) {
      if (_.isObject(obj)) { obj = JSON.stringify(obj, null, 2) }
      return trueAlert(obj)
    }
  }

  window.CONFIG = {
    images: {
      maxSize: 1600
    },
    // overriden at feature_detection setDebugSetting
    // as it depends on localStorageProxy
    debug: false
  }

  return window.CONFIG
}
