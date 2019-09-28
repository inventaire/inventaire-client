should = require 'should'

__ = require '../root'

{ parseQuery, buildPath } = __.require 'lib', 'location'

describe 'location utils', ->
  queries =
    good: 'category=book&text=whatever&claim=youknowhat&answer=imhappy'
    goodToo: '?category=book&text=whatever&claim=youknowhat&answer=imhappy'
    goodEncoded: 'label=ench%C3%A2nt%C3%A9'
    uncompleteButGood: '?category=book&text=&claim=&answer=imhappy'
    goodWithObject: 'action=man&data={"a":["abc",2]}'
    goodWithEncodedObject: 'action=man&data={%22wdt:P50%22:[%22wd:Q535%22]}'

  describe 'parseQuery', ->
    it 'should return an object', (done)->
      parseQuery(queries.good).should.be.an.Object()
      parseQuery(queries.goodToo).should.be.an.Object()
      parseQuery(queries.uncompleteButGood).should.be.an.Object()
      parseQuery().should.be.an.Object()
      parseQuery(null).should.be.an.Object()
      done()

    it "should forgive and forget the '?' before queries", (done)->
      queries.goodToo[0].should.equal '?'
      queryObj = parseQuery(queries.goodToo)
      for k, v of queryObj
        k[0].should.not.equal '?'
      _.isEqual(parseQuery(queries.goodToo), parseQuery(queries.good)).should.be.true
      done()

    it 'should decode encoded strings', (done)->
      queryObj = parseQuery queries.goodEncoded
      queryObj.should.deepEqual { label: 'enchânté' }
      done()

    it 'should parse JSON strings', (done)->
      queryObj = parseQuery queries.goodWithObject
      queryObj.should.deepEqual { action: 'man', data: { a: ['abc', 2] } }
      done()

    it 'should parse and decode encoded JSON strings', (done)->
      queryObj = parseQuery queries.goodWithEncodedObject
      queryObj.should.deepEqual { action: 'man', data: { 'wdt:P50': [ 'wd:Q535' ] } }
      done()

  describe 'buildPath', ->
    it 'should return a string with parameters', (done)->
      path = buildPath '/api', { action: 'man' }
      path.should.be.a.String()
      path.should.equal '/api?action=man'
      done()

    it 'should not add empty parameters', (done)->
      path = buildPath '/api', { action: 'man', boudu: null }
      path.should.equal '/api?action=man'
      done()

    it 'should stringify object value', (done)->
      path = buildPath '/api', { action: 'man', data: { a: [ 'abc', 2 ] } }
      path.should.equal '/api?action=man&data={"a":["abc",2]}'
      done()

    it 'should URI encode object values problematic query string characters', (done)->
      data = { a: 'some string with ?!MM%** problematic characters' }
      path = buildPath '/api', { data }
      path.should.equal '/api?data={"a":"some string with %3F!MM%** problematic characters"}'
      done()
