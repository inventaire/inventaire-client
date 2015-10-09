should = require 'should'

sharedLib = require './shared_lib'

shared_ = sharedLib 'utils'

describe 'Shared Utils', ->
  describe 'Full', ->
    it "should return a function", (done)->
      cb = -> console.log arguments
      fn = shared_.Full(cb, null, 1, 2, 3, 'whatever')
      fn.should.be.a.Function
      done()

    it "should not accept other argumens", (done)->
      sum = (args...)-> return args.reduce (a, b)-> a+b
      fn = shared_.Full(sum, null, 1, 2, 3)
      fn(4, 5, 6, 7, 8).should.equal 6
      fn(4568).should.equal 6
      done()
