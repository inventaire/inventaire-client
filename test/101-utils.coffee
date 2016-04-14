should = require 'should'
{ expect } = require 'chai'

_ = require './utils_builder'

describe 'Utils', ->
  describe 'cutBeforeWord', ->
    text = "Lorem ipsum dolor sit amet, consectetur adipisicing elit"
    result = _.cutBeforeWord text, 24
    it 'should return a string shorter or egal to the limit', (done)->
      (result.length <= 24 ).should.equal true
      done()
    it 'should cut between words', (done)->
      result.should.equal 'Lorem ipsum dolor sit'
      done()

  describe 'get', ->
    it 'should get the property where asked', (done)->
      _.get.should.be.a.Function()
      obj = {a: {b: {c: 123}}, d: 2}
      _.get(obj, 'd').should.equal 2
      _.get(obj, 'a.b.c').should.equal 123
      done()

    it "should return undefined if the value can't be accessed", (done)->
      obj = {a: {b: {c: 123}}, d: 2}
      expect(_.get(obj, 'a.b.d')).to.be.undefined
      expect(_.get(obj, 'nop.nop.nop')).to.be.undefined
      done()
