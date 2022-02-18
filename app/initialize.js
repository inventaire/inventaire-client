import './init_globals'
import '#lib/global_libs_extender'
import '#modules/general/scss/base.scss'
import '#lib/handlebars_helpers/init'
import '#lib/env_config'
import initPolyfills from '#lib/polyfills'
import testVideoInput from '#lib/has_video_input'
import initUnhandledErrorLogger from '#lib/unhandled_error_logger'
import initApp from './init_app.js'

// Init handler error before the app so that it can catch any error happenig there
initUnhandledErrorLogger()
testVideoInput()
initPolyfills()
initApp()
