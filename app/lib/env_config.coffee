# only addressing the general case
if location.hostname is 'localhost' then window.env = 'dev'
else window.env = 'prod'

module.exports = ->
  if env is 'dev'
    Promise.config
      longStackTraces: true
      warnings:
        wForgottenReturn: false

  window.CONFIG =
    images:
      maxSize: 1600
    # overriden at feature_detection setDebugSetting
    # as it depends on localStorageProxy
    debug: false
