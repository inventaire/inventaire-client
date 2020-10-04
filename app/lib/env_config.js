// roughtly addressing the general case
if (location.hostname.match(/^(localhost|192\.168)/)) {
  window.env = 'dev'
} else {
  window.env = 'prod'
}

if (window.env === 'dev') {
  const trueAlert = window.alert
  window.alert = function (obj) {
    if (_.isObject(obj)) obj = JSON.stringify(obj, null, 2)
    return trueAlert(obj)
  }
}
