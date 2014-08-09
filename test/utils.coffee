should = require 'should'

rootedRequire = (path)-> require '../app/' + path

_ = rootedRequire 'lib/utils'

describe 'log', (done)->
  str = "I'm a string *$*lazaù!m;÷;;aze"
  obj = {a:123,b:{c:1415125},d:[1,2,'AZ']}
  label = "I'm a label"

  it 'should return a string for string input', (done)->
    _.log(str).should.be.a.String
    _.log(str, label).should.be.a.String
    done()

  it 'should return an object for object input', (done)->
    _.log(obj).should.be.a.Object
    _.log(obj, label).should.be.a.Object
    done()