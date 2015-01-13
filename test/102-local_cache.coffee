__ = require '../root'

promises_ = __.require 'test', 'lib/promises'

should = require 'should'
sinon = require 'sinon'

global._ = _ = require './utils_builder'

_.extend global,
  LevelUp: require('level-test')()
  LevelJs: {}
  LevelPromise: require 'level-promise'
  LevelMultiply: require 'level-multiply'

Level = __.require 'lib', 'local_dbs'
LocalCache = __.require('lib', 'local_cache')(Level)

getOptions = ->
  spy = sinon.spy()
  options =
    name: _.uniqueId('fake_db_')
    remoteDataGetter: (ids)->
      spy()
      res = {}
      ids.forEach (id)-> res[id] = "hello #{id}!"
      return promises_.resolvedPromise(res)
    parseData: (data)-> data
  return [options, spy]

describe 'Local Cache', ->
  describe 'env', ->
    it 'should get a level-test instance', (done)->
      Level.should.be.a.Function
      done()

    it 'should find the lib', (done)->
      [opts, spy] = getOptions()
      local = new LocalCache opts
      local.should.be.an.Object
      done()

  describe 'get', ->
    it 'should accept one id or an Array ids', (done)->
      [opts, spy] = getOptions()
      local = new LocalCache opts
      local.get('what').then.should.be.a.Function
      local.get([1,2,3]).then.should.be.a.Function
      done()

    it 'should return a Promise', (done)->
      [opts, spy] = getOptions()
      local = new LocalCache opts
      local.get.should.be.an.Function
      local.get(['what']).then.should.be.a.Function
      done()

    it 'should call remoteDataGetter ones', (done)->
      [opts, spy] = getOptions()
      local = new LocalCache opts
      spy.callCount.should.equal 0
      local.get(['Atchoum','Joyeux','Simplet'])
      .then (res)->
        spy.callCount.should.equal 1
        done()
      .catch _.error.bind(_)

    it 'should not recall remoteDataGetter for the same ids', (done)->
      [opts, spy] = getOptions()
      local = new LocalCache opts
      spy.callCount.should.equal 0
      local.get(['Hitchy', 'Scratchy'])
      .then (res)->
        spy.callCount.should.equal 1
        local.get(['Hitchy', 'Scratchy'])
        .then (res)->
          spy.callCount.should.equal 1
          done()
      .catch _.error.bind(_)

    it 'should recall remoteDataGetter for different ids', (done)->
      [opts, spy] = getOptions()
      local = new LocalCache opts
      spy.callCount.should.equal 0
      local.get(['Melchior', 'Baltazar'])
      .then (res)->
        spy.callCount.should.equal 1
        local.get(['Gaspard', 'Kevin'])
        .then (res)->
          spy.callCount.should.equal 2
          done()
      .catch _.error.bind(_)

    it 'should return an indexed collection by default', (done)->
      [opts, spy] = getOptions()
      local = new LocalCache opts
      local.get(['do', 're'])
      .then (res)->
        res.should.be.an.Object
        _.objLength(res).should.equal 2
        res.do.should.equal "hello do!"
        res.re.should.equal "hello re!"
        local.get('stringinterface')
        .then (res2)->
          res2.should.be.an.Object
          _.objLength(res2).should.equal 1
          res2.stringinterface.should.equal "hello stringinterface!"
          done()
      .catch _.error.bind(_)

    it 'should return a collection if requested in options', (done)->
      [opts, spy] = getOptions()
      local = new LocalCache opts
      local.get(['mi', 'fa'], 'collection')
      .then (res)->
        res.should.be.an.Array
        res.length.should.equal 2
        res[0].should.equal "hello mi!"
        res[1].should.equal "hello fa!"
        local.get('stringinterface', 'collection')
        .then (res2)->
          res2.should.be.an.Array
          res2.length.should.equal 1
          res2[0].should.equal "hello stringinterface!"
          done()
      .catch _.error.bind(_)

    it 'should refresh when asked', (done)->
      [opts, spy] = getOptions()
      local = new LocalCache opts
      spy.callCount.should.equal 0
      local.get(['sol', 'la'])
      .then (res)->
        spy.callCount.should.equal 1
        local.get(['sol', 'la'], 'index', true)
        .then (res)->
          spy.callCount.should.equal 2
          done()
      .catch _.error.bind(_)