rootedRequire = (path)-> require '../app/' + path
sharedLib = (name)-> rootedRequire("lib/shared/#{name}")

Backbone = {}
app = {}
window = {}
_ = require 'underscore'

localLib = rootedRequire('lib/utils')(Backbone, _, app, window)
sharedL = sharedLib('utils')(_)
types = sharedLib 'types'

module.exports = _.extend _, localLib, sharedL, types