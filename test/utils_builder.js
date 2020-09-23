__ = require '../root'

global.Backbone = {}
global.app = {}
global.window =
  reportErr: ->
  # mimicking node_modules/sinon/lib/sinon/util/fake_server.js:38 result
  # for when window is undefined
  location: {}
global.document = {}
global.Promise = __.require 'lib', 'promises'
global.navigator =
  platform: 'None in particular'

global._ = _ = require 'underscore'

if process.env.CONSOLE is 'silent'
  csle = __.require 'lib', 'noop_console'
else
  csle = console

# no need to require jquery
# just faking what needs to be accessible to let tests pass
global.$ =
  extend: ->
  get: ->
  post: ->

loggers_ = __.require('lib', 'loggers')(_, csle)
types_ = __.require 'lib', 'types'
booleanTests_ = __.require 'lib', 'boolean_tests'
_.extend _, loggers_, types_

localUtils = __.require('lib', 'utils')(Backbone, _, $, app, window)

module.exports = _.extend _, localUtils, booleanTests_
