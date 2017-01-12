envConfig = require('lib/env_config')()
window.sharedLib = require 'lib/shared/shared_libs'
# used to allow monkey patching in tests
window.requireProxy = (path)-> require path

require('lib/feature_detection')()
# Init handler error before the app so that it can catch any error happenig there
require('lib/unhandled_error_logger')()
require('./init_app')()
