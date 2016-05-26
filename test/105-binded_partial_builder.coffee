should = require 'should'
__ = require '../root'

BindedPartialBuilder = __.require 'lib', 'binded_partial_builder'

obj =
  a: (x, y)-> return x + y + @z
  z: 5

describe 'BindedPartialBuilder', ->
  it 'should be a function', (done)->
    BindedPartialBuilder.should.be.a.Function()
    done()

  it 'should return a function', (done)->
    partialBuilder = BindedPartialBuilder obj, 'a'
    partialBuilder.should.be.a.Function()
    done()

  it 'should return a function that return a function binded to a context and possibly arguments', (done)->
    partialBuilder = BindedPartialBuilder obj, 'a'
    partialBuilder.should.be.a.Function()
    partial1 = partialBuilder 1
    partial1.should.be.a.Function()
    partial1(2).should.equal 8
    partial2_3 = partialBuilder 2, 3
    partial2_3.should.be.a.Function()
    partial2_3().should.equal 10
    partial2_3(123, 12512521).should.equal 10
    done()
