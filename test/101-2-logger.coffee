should = require 'should'
expect = require('chai').expect

_ = require './utils_builder'


describe 'Logger', ->


  describe 'log', ->
    it 'should return a string for string input', (done)->
      _.log('salut').should.be.a.String
      _.log('ca va?', 'oui oui').should.be.a.String
      done()

    it 'should return an object for object input', (done)->
      _.log({ach: 'so'}).should.be.a.Object
      _.log({ya: 'klar'}, 'doh').should.be.a.Object
      done()

    it 'should invert object and label when label comes first', (done)->
      _.log('su', {doh: 'ku'}).should.be.an.Object
      done()

    it 'should not invert if both label and object are strings', (done)->
      _.log('su', 'yo').should.be.equal 'su'
      done()

    it 'should not invert if only a string is provided', (done)->
      _.log('yo').should.be.equal 'yo'
      done()



  describe 'warn', ->
    it 'should always return undefined', (done)->
      expect(_.warn('yo')).to.be.undefined
      expect(_.warn('yo', {hello: 'wat'})).to.be.undefined
      expect(_.warn({hello: 'wat'}, 'yo')).to.be.undefined
      done()



  describe 'logIt', (done)->
    it 'should give String.prototype and Object.prototype a label', (done)->
      String::logIt.should.be.ok
      done()

    it 'should make Strings return Strings', (done)->
      'hello'.logIt('helli').should.be.a.String
      done()