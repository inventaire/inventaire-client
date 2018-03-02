should = require 'should'
sharedLib = require './shared_lib'
_ = require 'underscore'
shared_ = sharedLib('utils')(_)
_.extend _, shared_

describe 'Shared Utils', ->
  describe 'buildPath', ->
    it 'should return a string with parameters', (done)->
      path = _.buildPath '/api', { action: 'man' }
      path.should.be.a.String()
      path.should.equal '/api?action=man'
      done()

    it 'should not add empty parameters', (done)->
      path = _.buildPath '/api', { action: 'man', boudu: null }
      path.should.equal '/api?action=man'
      done()

    it 'should stringify object value', (done)->
      path = _.buildPath '/api', { action: 'man', data: { a: [ 'abc', 2 ] } }
      path.should.equal '/api?action=man&data={"a":["abc",2]}'
      done()

    it 'should URI encode object values problematic query string characters', (done)->
      data = { a: 'some string with ?!MM%** problematic characters' }
      path = _.buildPath '/api', { data }
      path.should.equal '/api?data={"a":"some string with %3F!MM%** problematic characters"}'
      done()
