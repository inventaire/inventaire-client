__ = require '../root'

should = require 'should'

global.location =
    hostname: 'localhost'
_ = global._ = require './utils_builder'
global.Handlebars = require 'handlebars'

helpers = __.require 'lib', 'handlebars_helpers/misc'

describe 'Handlebars helpers', ->
