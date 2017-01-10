should = require 'should'
sharedLib = require './shared_lib'
_ = require 'underscore'
shared_ = sharedLib('utils')(_)
_.extend _, shared_

describe 'Shared Utils', ->
  describe 'buildPath', ->
    it 'should return a string with parameters', (done)->
      path = _.buildPath 'http://hero/api', {action: 'man'}
      path.should.be.a.String()
      path.should.equal 'http://hero/api?action=man'
      done()

    it 'should not add empty parameters', (done)->
      path = _.buildPath 'http://hero/api', {action: 'man', boudu: null}
      path.should.equal 'http://hero/api?action=man'
      done()

  describe 'randomString', ->
    it 'should return a string', (done)->
      _.randomString(10).should.be.a.String()
      done()

    it 'should return a string with the right length (up to 24 or 25)', (done)->
      _.randomString(10).length.should.equal 10
      _.randomString(6).length.should.equal 6
      # Known abstraction leak: the minimalist implementation fails
      # to get above 24 characters. or sometimes 25
      _.randomString(100).length.should.not.equal 100
      done()

  describe 'Full', ->
    it "should return a function", (done)->
      cb = -> console.log arguments
      fn = _.Full(cb, null, 1, 2, 3, 'whatever')
      fn.should.be.a.Function()
      done()

    it "should not accept other argumens", (done)->
      sum = (args...)-> return args.reduce (a, b)-> a+b
      fn = _.Full(sum, null, 1, 2, 3)
      fn(4, 5, 6, 7, 8).should.equal 6
      fn(4568).should.equal 6
      done()
