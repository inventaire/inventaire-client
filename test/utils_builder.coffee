__ = require '../root'

global.Backbone = {}
global.app = {}
global.window =
  reportErr: ->
global.location = {}

global.sharedLib = (lib)-> __.require 'shared', lib

_ = require 'underscore'

localLib = __.require('lib', 'utils')(Backbone, _, app, window)
sharedL = __.require('shared','utils')(_)
types = __.require 'shared', 'types'

module.exports = _.extend _, localLib, sharedL, types