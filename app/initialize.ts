import './init_globals'
import { waitingForPolyfills } from './init_polyfills'
import '#lib/global_libs_extender'
import '#general/scss/base.scss'
import '#lib/handlebars_helpers/init'
import '#lib/env_config'
import testVideoInput from '#lib/has_video_input'
import initUnhandledErrorLogger from '#lib/unhandled_error_logger'
import initApp from './init_app.ts'

// Init handler error before the app so that it can catch any error happenig there
initUnhandledErrorLogger()
testVideoInput()

waitingForPolyfills
.then(initApp)
