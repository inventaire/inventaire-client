__ = require '../root'

promises_ = __.require 'test', 'lib/promises'

should = require 'should'
sinon = require 'sinon'

global.dbs = {}
global._ = _ = require './utils_builder'

_.extend global,
  # /!\ level-test takes time to delete the previous instance
  # which might get some tests to timeout when run in watch mode
  LevelUp: require('level-test')({ mem: true })
  LevelJs: {}
  LevelMultiply: require 'level-multiply'
  Promise: require 'bluebird'

# doesn't need to be init before
# as levelup will use level-test
LocalDB = __.require('lib', 'data/local_db').build(global, _)

describe 'Local DB', ->
  describe 'env', ->
    it 'should get a level-test instance', (done)->
      LocalDB.should.be.a.Function()
      localdb = LocalDB 'fake-db-name'
      localdb.get.should.be.a.Function()
      localdb.put.should.be.a.Function()
      localdb.batch.should.be.a.Function()
      localdb.reset.should.be.a.Function()
      localdb.inspect.should.be.a.Function()
      done()

  describe 'batch', ->
    it 'should return a promise', (done)->
      localdb = LocalDB 'fake-db-name-1'
      ops = [
        {type: 'put', key: 'yo', value: 123}
        {type: 'put', key: 'da', value: 456}
      ]
      localdb.batch ops
      .then -> done()
      .then.should.be.a.Function()

  describe 'reset', ->
    it 'should return a promise', (done)->
      localdb = LocalDB 'fake-db-name-2'
      ops = [
        {type: 'put', key: 'yo', value: 123}
        {type: 'put', key: 'da', value: 456}
      ]
      localdb.batch ops
      .then ->
        localdb.reset()
        .then.should.be.a.Function()

        done()
