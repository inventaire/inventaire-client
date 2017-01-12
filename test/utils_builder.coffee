__ = require '../root'

global.Backbone = {}
global.app = {}
global.window =
  reportErr: ->
  # mimicking node_modules/sinon/lib/sinon/util/fake_server.js:38 result
  # for when window is undefined
  location: {}
global.location = {}
global.Promise = require 'bluebird'
global.navigator =
  platform: 'None in particular'

sharedLib = require './shared_lib'

global._ = _ = require 'underscore'

if process.env.CONSOLE is 'silent'
  csle = __.require 'lib', 'noop_console'
else
  csle = console

loggers_ = __.require('lib', 'loggers')(_, csle)
types_ = sharedLib('types')(_)
_.extend _, loggers_, types_

# no need to require jquery
# just faking what needs to be accessible to let tests pass
global.$ =
  extend: ->
  get: ->
  post: ->

localLib = __.require('lib', 'utils')(Backbone, _, $, app, window)

module.exports = _.extend _, localLib
