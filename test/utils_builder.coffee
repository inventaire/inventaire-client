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

localLib = __.require('lib', 'utils')(Backbone, _, app, window, csle)
sharedL = __.require('shared','utils')(_)
types = __.require 'shared', 'types'

module.exports = _.extend _, localLib, sharedL, types