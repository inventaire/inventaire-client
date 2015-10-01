module.exports = (Backbone, _, app, window)->
  # _ starts as a global object with just the underscore lib

  # extending _ with invUtils functions
  _ = invUtils _

  csle = if CONFIG.debug then window.console else require 'lib/noop_console'

  # add client-specific utils
  local = require('lib/utils')(Backbone, _, app, window, csle)
  # add utils shared between the server and the client
  # but not yet extracted to inv-utils
  shared_ = sharedLib 'utils'
  _.extend _, local, shared_

  # http requests handler returning promises
  _.preq = require 'lib/preq'

  _.isMobile = require 'lib/mobile_check'

  return _