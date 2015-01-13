__ = require '../root'

should = require 'should'

global.location =
    hostname: 'localhost'
_ = global._ = require './utils_builder'
global.Handlebars = require 'handlebars'

convertMarkdown = __.require 'scripts', 'lib/convert_markdown'

describe 'Handlebars helpers', ->
  describe 'markdown', ->
    it 'should return a string', (done)->
      text = 'buongiorno principessa'
      convertMarkdown(text).should.be.an.String
      done()

    it 'should convert bold text', (done)->
      text = '**sloubi** 1, **sloubi** 2...'
      result = '<strong>sloubi</strong> 1, <strong>sloubi</strong> 2...'
      convertMarkdown(text).should.equal result
      done()

    it 'should convert a link', (done)->
      anchor = 'The Truth'
      url = 'http://zombo.com/'
      text = "blabla [#{anchor}](#{url}) blabla"
      result = convertMarkdown(text)
      _.log result, 'result'
      re = new RegExp "a href='#{url}' \.\+>#{anchor}</a>"
      re.test(result).should.equal true
      done()

    it 'should convert several links', (done)->
      anchor = 'The Truth'
      url = 'http://zombo.com/'
      text = "blabla [#{anchor}](#{url}) blabla [#{anchor}](#{url}) no???"
      result = convertMarkdown(text)
      _.log result, 'result'
      re = new RegExp "a href='#{url}' \.\+>#{anchor}</a>"
      re.test(result).should.equal true
      done()

    it 'should convert links inside parenthesis', (done)->
      anchor = 'PouchDB'
      url = 'http://pouchdb.com/'
      text = "blabla you control (using [#{anchor}](#{url}) replication). In the future, blabla"
      result = convertMarkdown(text)
      _.log result, 'result'
      re = new RegExp "a href='#{url}' \.\+>#{anchor}</a>"
      re.test(result).should.equal true
      done()
