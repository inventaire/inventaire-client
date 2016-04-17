should = require 'should'
expect = require('chai').expect

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
      expect(_.warn('yo')).to.be.undefined
      expect(_.warn('yo', {hello: 'wat'})).to.be.undefined
      expect(_.warn({hello: 'wat'}, 'yo')).to.be.undefined
      done()

  # err = new Error('all your base are belong to us')
