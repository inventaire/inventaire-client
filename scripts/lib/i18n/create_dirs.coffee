Promise = require '../bluebird'
mkdirp = Promise.promisify require('mkdirp')
__ = require '../paths'

module.exports = ->
  Promise.all [
    mkdirp __.distRoot
    mkdirp __.src.fk('archive')
    mkdirp __.src.sk('archive')
    mkdirp __.src.wd('archive')
  ]
