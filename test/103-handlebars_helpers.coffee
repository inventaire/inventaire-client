rootedRequire = (path)-> require '../app/' + path

should = require 'should'

_ = global._ = require './utils_builder'
global.Handlebars = {}

helpers = rootedRequire 'lib/handlebars_helpers/misc'

describe 'Handlebars helpers', ->
  describe 'markdown', ->
    it 'should return a string', (done)->
      text = 'buongiorno principessa'
      helpers.markdown(text).should.be.a.String
      done()

    it 'should convert bold text', (done)->
      text = '**sloubi** 1, **sloubi** 2...'
      result = '<strong>sloubi</strong> 1, <strong>sloubi</strong> 2...'
      helpers.markdown(text).should.equal result
      done()

    it 'should convert a link', (done)->
      anchor = 'The Truth'
      url = 'http://zombo.com/'
      text = "blabla [#{anchor}](#{url}) blabla"
      result = helpers.markdown(text)
      _.log result, 'result'
      re = new RegExp "a href='#{url}' \.\+>#{anchor}</a>"
      re.test(result).should.equal true
      done()

    it 'should convert several links', (done)->
      anchor = 'The Truth'
      url = 'http://zombo.com/'
      text = "blabla [#{anchor}](#{url}) blabla [#{anchor}](#{url}) no???"
      result = helpers.markdown(text)
      _.log result, 'result'
      re = new RegExp "a href='#{url}' \.\+>#{anchor}</a>"
      re.test(result).should.equal true
      done()