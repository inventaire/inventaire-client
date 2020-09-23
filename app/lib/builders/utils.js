export default function () {
  // _ starts as a global object with just the underscore lib
  // It needs to be explicitly definied hereafter to avoid
  // the variable _ to be overriden in this scope
  const { _ } = window

  const csle = CONFIG.debug ? window.console : require('lib/noop_console')

  // client-specific utils
  const local_ = require('lib/utils')(Backbone, _, $, app, window)
  const loggers_ = require('lib/loggers')(_, csle)
  const types_ = require('lib/types')
  const regex_ = require('lib/regex')
  const booleanTests_ = require('lib/boolean_tests')

  _.extend(_, local_, types_, booleanTests_, loggers_)

  // http requests handler returning promises
  _.preq = require('lib/preq')

  _.isMobile = require('lib/mobile_check')

  return _
};
