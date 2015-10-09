__ = require '../root'

global.sharedLib = sharedLib = (lib)-> __.require 'shared', lib
module.exports = sharedLib