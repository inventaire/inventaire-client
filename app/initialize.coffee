window.Promise = require 'bluebird'

window.$ = window.jQuery = require 'jquery'
require 'jquery-visible'
require 'jquery-inview'

window._ = require 'underscore'

window.Backbone = require 'backbone'
Backbone.$ = $
window.Marionette = require 'backbone.marionette'
window.FilteredCollection = require 'backbone-filtered-collection'
require 'backbone-nested'

envConfig = require('lib/env_config')()
# used to allow monkey patching in tests
window.requireProxy = (path)-> require path

require('lib/feature_detection')()
# Init handler error before the app so that it can catch any error happenig there
require('lib/unhandled_error_logger')()
require('./init_app')()
