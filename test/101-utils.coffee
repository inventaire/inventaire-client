should = require 'should'

rootedRequire = (path)-> require '../app/' + path

underscore = require 'underscore'
_ = extend(rootedRequire 'lib/utils', underscore)
extend = underscore.extend

Data = ->
  @str = "I'm a string *$*lazaù!m;÷;;aze"
  @obj = {a:123,b:{c:1415125},d:[1,2,'AZ']}
  @label = "I'm a label"




describe 'log', (done)->
  d = new Data
  it 'should return a string for string input', (done)->
    _.log(d.str).should.be.a.String
    _.log(d.str, d.label).should.be.a.String
    done()

  it 'should return an object for object input', (done)->
    _.log(d.obj).should.be.a.Object
    _.log(d.obj, d.label).should.be.a.Object
    done()




describe 'label', (done)->
  d = new Data
  it 'should give String.prototype and Object.prototype a label', (done)->
    String::label.should.be.ok
    done()

  it 'should make Strings return Strings', (done)->
    'hello'.label('label text').should.be.a.String
    d.str.label('label text').should.be.a.String
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
    _.hasDiff(_.parseQuery(queries.goodToo), _.parseQuery(queries.good)).should.be.false
    done()


# describe 'appendParam', (done)->
#   it 'should return an object', (done)->
#     _.appendParam('/blabla/bla?' + queries.good, {gloubi: 'boulga'}).should.be.an.Object

# => need browserify for underscore dependency
