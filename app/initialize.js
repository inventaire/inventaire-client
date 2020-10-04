// Customized backbone.marionette
// Sets globals: $, jQuery, Backbone, Marionette, FilteredCollection
import 'backbone.marionette'
import initApp from './init_app'
import envConfig from 'lib/env_config'
import initPolyfills from 'lib/polyfills'
import testVideoInput from 'lib/has_video_input'
import setupLocalStorageProxy from 'lib/local_storage'
import initUnhandledErrorLogger from 'lib/unhandled_error_logger'

// import Promise from '~/lib/promises'

// Init handler error before the app so that it can catch any error happenig there
initUnhandledErrorLogger()
envConfig()
initPolyfills()
setupLocalStorageProxy()
testVideoInput()
initApp()
