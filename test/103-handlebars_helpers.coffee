rootedRequire = (path)-> require '../app/' + path

should = require 'should'

global.location =
    hostname: 'localhost'
_ = global._ = require './utils_builder'
global.Handlebars = require 'handlebars'

helpers = rootedRequire 'lib/handlebars_helpers/misc'

describe 'Handlebars helpers', ->
