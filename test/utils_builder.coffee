__ = require '../root'

global.Backbone = {}
global.app = {}
global.window =
  reportErr: ->
global.location = {}

global.sharedLib = (lib)-> __.require 'shared', lib

# desactivating logs
csle =
  log: ->
  warn: ->
  error: ->
  info: ->

_ = require 'underscore'

invUtils = require('inv-utils')(_)
localLib = __.require('lib', 'utils')(Backbone, _, app, window, csle)

module.exports = _.extend _, localLib, invUtils