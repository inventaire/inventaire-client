// Customized backbone.marionette
// Sets globals: $, jQuery, Backbone, Marionette, FilteredCollection
import 'backbone.marionette'
import initApp from './init_app'
import envConfig from 'lib/env_config'

// import Promise from '~/lib/promises'

envConfig()
initApp()

// require('lib/feature_detection')()
// // Init handler error before the app so that it can catch any error happenig there
// require('lib/unhandled_error_logger')()
