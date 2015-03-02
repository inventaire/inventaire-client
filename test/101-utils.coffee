# tuto STUB => https://nicolas.perriault.net/code/2013/testing-frontend-javascript-code-using-mocha-chai-and-sinon/

should = require 'should'
sinon = require 'sinon'

_ = require './utils_builder'


describe 'Utils', ->
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

  describe 'logIt', (done)->
    it 'should give String.prototype and Object.prototype a label', (done)->
      String::logIt.should.be.ok
      done()

    it 'should make Strings return Strings', (done)->
      'hello'.logIt('helli').should.be.a.String
      done()

  describe 'buildPath', (done)->
    it 'should return a string with parameters', (done)->
      path = _.buildPath 'http://hero/api', {action: 'man'}
      path.should.be.a.String
      path.should.equal 'http://hero/api?action=man'
      done()

    it 'should not add empty parameters', (done)->
      path = _.buildPath 'http://hero/api', {action: 'man', boudu: null}
      path.should.equal 'http://hero/api?action=man'
      done()

  queries =
    good: 'category=book&text=whatever&claim=youknowhat&answer=imhappy'
    goodToo: '?category=book&text=whatever&claim=youknowhat&answer=imhappy'
    uncompleteButGood: '?category=book&text=&claim=&answer=imhappy'

  describe 'parseQuery', (done)->
    it 'should return an object', (done)->
      _.parseQuery(queries.good).should.be.an.Object
      _.parseQuery(queries.goodToo).should.be.an.Object
      _.parseQuery(queries.uncompleteButGood).should.be.an.Object
      _.log _.parseQuery(queries.goodToo), queries.goodToo
      done()

    it "should forgive and forget the '?' before queries", (done)->
      queries.goodToo[0].should.equal '?'
      queryObj = _.parseQuery(queries.goodToo)
      for k,v of queryObj
        k[0].should.not.equal '?'
      _.isEqual(_.parseQuery(queries.goodToo), _.parseQuery(queries.good)).should.be.true
      done()


  describe 'idGenerator', (done)->
    it 'should return a string', (done)->
      _.idGenerator(10).should.be.a.String
      done()

    it 'should return a string with the right length', (done)->
      _.idGenerator(10).length.should.equal 10
      _.idGenerator(6).length.should.equal 6
      _.idGenerator(100).length.should.equal 100
      done()

    it 'should return a string withoutFigures is asked', (done)->
      /[0-9]/.test(_.idGenerator(100)).should.be.true
      /[0-9]/.test(_.idGenerator(100, true)).should.be.false
      done()


  describe 'pickToArray', (done)->
    it 'should return an array', (done)->
      obj =
        a: 15
        b: 25
        c: 35
      array = ['b', 'c']
      _.pickToArray(obj, array).should.be.an.Array
      _.pickToArray(obj, array).length.should.equal 2
      _.pickToArray(obj, array)[0].should.equal 25
      _.pickToArray(obj, array)[1].should.equal 35
      done()


  describe 'duplicatesArray', (done)->
    it 'should return an array filled with the string', (done)->
      hops = _.duplicatesArray('hop', 3)
      hops.length.should.equal 3
      hops.forEach (el)-> el.should.equal 'hop'

      blops = _.duplicatesArray('blop', 100)
      blops.length.should.equal 100
      blops.forEach (el)-> el.should.equal 'blop'
      done()
