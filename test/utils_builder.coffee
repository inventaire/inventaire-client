__ = require '../root'

global.Backbone = {}
global.app = {}
global.window =
  reportErr: ->
  # mimicking node_modules/sinon/lib/sinon/util/fake_server.js:38 result
  # for when window is undefined
  location: {}
global.location = {}
global.wdk = require 'wikidata-sdk'
global.Promise = require 'bluebird'

sharedLib = require './shared_lib'

if process.env.CONSOLE is 'silent'
  csle = __.require 'lib', 'noop_console'
else
  csle = console

global._ = _ = require 'underscore'

invUtils = require('inv-utils')(_)
localLib = __.require('lib', 'utils')(Backbone, _, app, window, csle)

module.exports = _.extend _, localLib, invUtils
