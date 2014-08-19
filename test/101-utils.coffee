should = require 'should'

rootedRequire = (path)-> require '../app/' + path

_ = rootedRequire 'lib/utils'

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