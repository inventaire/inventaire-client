should = require 'should'
_ = require './utils_builder'

describe 'Logger', ->
  describe 'log', ->
    it 'should return a string for string input', (done)->
      _.log('salut').should.be.a.String()
      _.log('ca va?', 'oui oui').should.be.a.String()
      done()

    it 'should return an object for object i nput', (done)->
      _.log({ach: 'so'}).should.be.a.Object()
      _.log({ya: 'klar'}, 'doh').should.be.a.Object()
      done()

  describe 'Log', ->
    it 'should return _.log with a binded-label', (done)->
      waitingLog = _.Log('hallo')
      waitingLog.should.be.a.Function()
      waitingLog({hey: "azegzagazere"})
      waitingLog({hey: "there"}).should.be.an.Object()
      done()

  describe 'warn', ->
    it 'should always return undefined', (done)->
      should(_.warn('yo')).not.be.ok()
      should(_.warn('yo', {hello: 'wat'})).not.be.ok()
      should(_.warn({hello: 'wat'}, 'yo')).not.be.ok()
      done()

  describe 'error', ->
    it 'should always return undefined', (done)->
      should(_.error('yo')).not.be.ok()
      should(_.error('yo', {hello: 'wat'})).not.be.ok()
      should(_.error({hello: 'wat'}, 'yo')).not.be.ok()
      done()

  describe 'Error', ->
    it 'should return an error logger that catches errors', (done)->
      should(_.Error('yo label')('yo')).not.be.ok()
      should(_.Error('yo label')({hello: 'wat'})).not.be.ok()

      Promise.reject new Error('damned 1')
      .catch _.Error('catching!')
      .then -> done()

  describe 'ErrorRethrow', ->
    it 'should return an error logger that rethrows errors', (done)->
      Promise.reject new Error('damned 2')
      .catch _.ErrorRethrow('rethrowing!')
      .catch -> done()
      # should(_.ErrorRethrow('yo label')('yo')).not.be.ok()
      # should(_.ErrorRethrow('yo label')({hello: 'wat'})).not.be.ok()
