should = require 'should'

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
      should(_.get(obj, 'a.b.d')).not.be.ok()
      should(_.get(obj, 'nop.nop.nop')).not.be.ok()
      done()

  queries =
    good: 'category=book&text=whatever&claim=youknowhat&answer=imhappy'
    goodToo: '?category=book&text=whatever&claim=youknowhat&answer=imhappy'
    uncompleteButGood: '?category=book&text=&claim=&answer=imhappy'

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
      for k,v of queryObj
        k[0].should.not.equal '?'
      _.isEqual(_.parseQuery(queries.goodToo), _.parseQuery(queries.good)).should.be.true
      done()

  describe 'pickToArray', ->
    it 'should return an array', (done)->
      obj =
        a: 15
        b: 25
        c: 35
      array = ['b', 'c']
      _.pickToArray(obj, array).should.be.an.Array()
      _.pickToArray(obj, array).length.should.equal 2
      _.pickToArray(obj, array)[0].should.equal 25
      _.pickToArray(obj, array)[1].should.equal 35
      done()
