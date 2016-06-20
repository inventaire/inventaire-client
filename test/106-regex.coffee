should = require 'should'

sharedLib = require './shared_lib'

{ EntityUri } = sharedLib 'regex'

describe 'Regex', ->
  describe 'EntityUri', ->
    it "should be a regex", (done)->
      (EntityUri instanceof RegExp).should.be.true()
      done()

    it "should accept valid wikidata entities uri", (done)->
      EntityUri.test('wd:Q1').should.be.true()
      EntityUri.test('wd:Q1123').should.be.true()
      done()

    it "should reject invalid wikidata entities uri", (done)->
      EntityUri.test('Q1123').should.be.false()
      EntityUri.test('wd:P1123').should.be.false()
      EntityUri.test('wd:Q').should.be.false()
      done()

    it "should accept valid inventaire entities uri", (done)->
      EntityUri.test('inv:1234567890abcdef1234567890abcdef').should.be.true()
      done()

    it "should reject invalid inventaire entities uri", (done)->
      EntityUri.test('inv:1234567890abcdef1234567890abcde').should.be.false()
      EntityUri.test('inv:z234567890abcdef1234567890abcdef').should.be.false()
      EntityUri.test('inz:1234567890abcdef1234567890abcdef').should.be.false()
      EntityUri.test('1234567890abcdef1234567890abcdef').should.be.false()
      done()

    it "should accept valid isbn uri", (done)->
      EntityUri.test('isbn:9781231231231').should.be.true()
      EntityUri.test('isbn:1231231231').should.be.true()
      EntityUri.test('isbn:123123123X').should.be.true()
      done()

    it "should reject invalid inventaire entities uri", (done)->
      EntityUri.test('isbn:978-123123123X').should.be.false()
      EntityUri.test('isbn:978123123123').should.be.false()
      EntityUri.test('isbn:97812312312').should.be.false()
      done()
