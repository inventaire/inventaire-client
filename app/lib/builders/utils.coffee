module.exports = ->
  # _ starts as a global object with just the underscore lib
  # It needs to be explicitly definied hereafter to avoid
  # the variable _ to be overriden in this scope
  { _ } = window

  csle = if CONFIG.debug then window.console else require 'lib/noop_console'

  # client-specific utils
  local_ = require('lib/utils')(Backbone, _, $, app, window)
  loggers_ = require('lib/loggers')(_, csle)
  # utils shared between the server and the client
  shared_ = sharedLib('utils')(_)
  types_ = sharedLib('types')(_)
  regex_ = sharedLib 'regex'
  tests_ = sharedLib('tests')(regex_, _)

  _.extend _, local_, shared_, types_, tests_, loggers_

  # http requests handler returning promises
  _.preq = require 'lib/preq'

  _.isMobile = require 'lib/mobile_check'

  return _
