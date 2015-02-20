featureDetection = require 'lib/feature_detection'
initApp = require './init_app'

featureDetection()
.then initApp
.catch (err)->
  console.error 'featureDetection err', err

require('lib/unhandled_error_logger').initialize()
window.sharedLib = sharedLib = require('lib/shared/shared_libs')
