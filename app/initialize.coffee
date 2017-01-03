envConfig = require('lib/env_config')()
window.sharedLib = require 'lib/shared/shared_libs'
# used to allow monkey patching in tests
window.requireProxy = (path)-> require path

require('lib/feature_detection')()
require('./init_app')()
require('lib/unhandled_error_logger')()
