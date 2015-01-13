__ = require '../root'

Backbone = {}
app = {}
window = {}
global.location = {}

_ = require 'underscore'

localLib = __.require('lib', 'utils')(Backbone, _, app, window)
sharedL = __.require('shared','utils')(_)
types = __.require 'shared', 'types'

module.exports = _.extend _, localLib, sharedL, types