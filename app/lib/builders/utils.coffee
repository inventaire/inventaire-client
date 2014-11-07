module.exports = (Backbone, _, app, window)->

  # _ starts as a global object with just the underscore lib

  local = require('lib/utils')(Backbone, _, app, window)
  shared = sharedLib('utils')(_)
  _.extend _, local, shared

  # http requests handler returning promises
  _.preq = require 'lib/preq'

  _.isMobile = require 'lib/mobile_check'

  return _