__ = require '../root'

global.Backbone = {}
global.app = {}
global.window =
  reportErr: ->
global.location = {}
global.wdk = require 'wikidata-sdk'

sharedLib = require './shared_lib'

# desactivating logs
csle = __.require 'lib', 'noop_console'

global._ = _ = require 'underscore'

invUtils = require('inv-utils')(_)
localLib = __.require('lib', 'utils')(Backbone, _, app, window, csle)

module.exports = _.extend _, localLib, invUtils
