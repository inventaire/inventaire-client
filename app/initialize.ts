import './init_globals.ts'
import '#general/scss/base.scss'
import '#app/lib/env_config'
import initUnhandledErrorLogger from '#app/lib/unhandled_error_logger'
import initApp from './init_app.ts'
import { waitingForPolyfills } from './init_polyfills.ts'

// Init handler error before the app so that it can catch any error happenig there
initUnhandledErrorLogger()

waitingForPolyfills.then(initApp)
