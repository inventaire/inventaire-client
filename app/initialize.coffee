envConfig = require('lib/env_config')()
window.sharedLib = require 'lib/shared/shared_libs'
# used to allow monkey patching in tests
window.requireProxy = (path)-> require path

isModernBrowser = require('lib/feature_detection')()

# Init handler error before the app so that it can catch any error happenig there
require('lib/unhandled_error_logger')()

if isModernBrowser then require('./init_app').init()
else require('modules/general/views/old_browser_screen')()
