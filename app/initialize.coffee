envConfig = require('lib/env_config')()
window.sharedLib = require 'lib/shared/shared_libs'
featureDetection = require 'lib/feature_detection'
initApp = require './init_app'

reportError = (label, err)->
  # _.error might not be defined yet, so to increase the chances
  # to get the error reported server-side, we let it fallback
  # to bluebird's onPossiblyUnhandledRejection handler
  if _?.error? then _.error label, err
  else throw err


featureDetection()
.catch reportError.bind(null, 'featureDetection err')
.then initApp
# letting Bluebird 'PossiblyUnhandledError' handle it
# as it seems it gives a more useful stack trace of the error
# .catch reportError.bind(null, 'initApp err')

require('lib/unhandled_error_logger').initialize()
