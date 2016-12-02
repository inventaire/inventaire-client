# roughtly addressing the general case
if location.hostname.match /^(localhost|192\.168)/ then window.env = 'dev'
else window.env = 'prod'

promiseConfig =
  cancellation: true

module.exports = ->
  if env is 'dev'
    _.extend promiseConfig,
      longStackTraces: true
      warnings:
        wForgottenReturn: false

    trueAlert = window.alert
    window.alert = (obj)->
      if _.isObject obj then obj = JSON.stringify(obj, null, 2)
      trueAlert obj

  Promise.config promiseConfig

  window.CONFIG =
    images:
      maxSize: 1600
    # overriden at feature_detection setDebugSetting
    # as it depends on localStorageProxy
    debug: false
