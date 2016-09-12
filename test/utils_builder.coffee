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

global._ = _ = require 'underscore'

# no need to require jquery
# just faking what needs to be accessible to let tests pass
global.$ =
  extend: ->

localLib = __.require('lib', 'utils')(Backbone, _, $, app, window)

module.exports = _.extend _, localLib
