should = require 'should'

_ = require './utils_builder'

describe 'Utils', ->
  describe 'cutBeforeWord', ->
    text = 'Lorem ipsum dolor sit amet, consectetur adipisicing elit'
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
      obj = { a: { b: { c: 123 } }, d: 2 }
      _.get(obj, 'd').should.equal 2
      _.get(obj, 'a.b.c').should.equal 123
      done()

    it "should return undefined if the value can't be accessed", (done)->
      obj = { a: { b: { c: 123 } }, d: 2 }
      should(_.get(obj, 'a.b.d')).not.be.ok()
      should(_.get(obj, 'nop.nop.nop')).not.be.ok()
      done()

  queries =
    good: 'category=book&text=whatever&claim=youknowhat&answer=imhappy'
    goodToo: '?category=book&text=whatever&claim=youknowhat&answer=imhappy'
    goodEncoded: 'label=ench%C3%A2nt%C3%A9'
    uncompleteButGood: '?category=book&text=&claim=&answer=imhappy'
    goodWithObject: 'action=man&data={"a":["abc",2]}'
    goodWithEncodedObject: 'action=man&data={%22wdt:P50%22:[%22wd:Q535%22]}'

  describe 'parseQuery', ->
    it 'should return an object', (done)->
      _.parseQuery(queries.good).should.be.an.Object()
      _.parseQuery(queries.goodToo).should.be.an.Object()
      _.parseQuery(queries.uncompleteButGood).should.be.an.Object()
      _.parseQuery().should.be.an.Object()
      _.parseQuery(null).should.be.an.Object()
      _.log _.parseQuery(queries.goodToo), queries.goodToo
      done()

    it "should forgive and forget the '?' before queries", (done)->
      queries.goodToo[0].should.equal '?'
      queryObj = _.parseQuery(queries.goodToo)
      for k, v of queryObj
        k[0].should.not.equal '?'
      _.isEqual(_.parseQuery(queries.goodToo), _.parseQuery(queries.good)).should.be.true
      done()

    it 'should decode encoded strings', (done)->
      queryObj = _.parseQuery queries.goodEncoded
      queryObj.should.deepEqual { label: 'enchânté' }
      done()

    it 'should parse JSON strings', (done)->
      queryObj = _.parseQuery queries.goodWithObject
      queryObj.should.deepEqual { action: 'man', data: { a: ['abc', 2] } }
      done()

    it 'should parse and decode encoded JSON strings', (done)->
      queryObj = _.parseQuery queries.goodWithEncodedObject
      queryObj.should.deepEqual { action: 'man', data: { 'wdt:P50': [ 'wd:Q535' ] } }
      done()

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
