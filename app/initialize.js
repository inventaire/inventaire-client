import 'modules/general/scss/base.scss'
// Customized backbone.marionette
// Sets globals: $, jQuery, Backbone, Marionette, FilteredCollection
import 'backbone.marionette'
import 'lib/handlebars_helpers/init'
import 'lib/global_libs_extender'
import 'lib/env_config'
import initPolyfills from 'lib/polyfills'
import testVideoInput from 'lib/has_video_input'
import initUnhandledErrorLogger from 'lib/unhandled_error_logger'
import initApp from './init_app'

// Init handler error before the app so that it can catch any error happenig there
initUnhandledErrorLogger()
testVideoInput()
initPolyfills()
initApp()
