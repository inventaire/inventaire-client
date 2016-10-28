should = require 'should'

sharedLib = require './shared_lib'

{ EntityUri, SimpleDay, Url, IpfsPath } = sharedLib 'regex'

describe 'Regex', ->
  describe 'EntityUri', ->
    it 'should be a regex', (done)->
      (EntityUri instanceof RegExp).should.be.true()
      done()

    it 'should accept valid wikidata entities uri', (done)->
      EntityUri.test('wd:Q1').should.be.true()
      EntityUri.test('wd:Q1123').should.be.true()
      done()

    it 'should reject invalid wikidata entities uri', (done)->
      EntityUri.test('Q1123').should.be.false()
      EntityUri.test('wd:P1123').should.be.false()
      EntityUri.test('wd:Q').should.be.false()
      done()

    it 'should accept valid inventaire entities uri', (done)->
      EntityUri.test('inv:1234567890abcdef1234567890abcdef').should.be.true()
      done()

    it 'should reject invalid inventaire entities uri', (done)->
      EntityUri.test('inv:1234567890abcdef1234567890abcde').should.be.false()
      EntityUri.test('inv:z234567890abcdef1234567890abcdef').should.be.false()
      EntityUri.test('inz:1234567890abcdef1234567890abcdef').should.be.false()
      EntityUri.test('1234567890abcdef1234567890abcdef').should.be.false()
      done()

    it 'should accept valid isbn uri', (done)->
      EntityUri.test('isbn:9781231231231').should.be.true()
      EntityUri.test('isbn:1231231231').should.be.true()
      EntityUri.test('isbn:123123123X').should.be.true()
      done()

    it 'should reject invalid inventaire entities uri', (done)->
      EntityUri.test('isbn:978-123123123X').should.be.false()
      EntityUri.test('isbn:978123123123').should.be.false()
      EntityUri.test('isbn:97812312312').should.be.false()
      done()

  describe 'SimpleDay', ->
    it 'should accept a year alone', (done)->
      SimpleDay.test('1972').should.be.true()
      SimpleDay.test('972').should.be.true()
      SimpleDay.test('72').should.be.true()
      SimpleDay.test('2').should.be.true()
      SimpleDay.test('9972').should.be.true()
      SimpleDay.test('11972').should.be.false()
      done()

    it 'should accept negative years', (done)->
      SimpleDay.test('-1972').should.be.true()
      SimpleDay.test('-972').should.be.true()
      SimpleDay.test('-72').should.be.true()
      SimpleDay.test('-2').should.be.true()
      done()

    it 'should accept a day', (done)->
      SimpleDay.test('1972-01-01').should.be.true()
      SimpleDay.test('972-02-02').should.be.true()
      SimpleDay.test('72-03-03').should.be.true()
      SimpleDay.test('2-03-03').should.be.true()
      done()

    it 'should accept a day in negative year', (done)->
      SimpleDay.test('-1972-01-01').should.be.true()
      SimpleDay.test('-972-02-02').should.be.true()
      SimpleDay.test('-72-03-03').should.be.true()
      SimpleDay.test('-2-03-03').should.be.true()
      done()

    it 'should reject a year and month without a day', (done)->
      SimpleDay.test('1972-01').should.be.false()
      SimpleDay.test('-1972-01').should.be.false()
      SimpleDay.test('972-02').should.be.false()
      SimpleDay.test('-972-02').should.be.false()
      SimpleDay.test('72-03').should.be.false()
      SimpleDay.test('-72-03').should.be.false()
      SimpleDay.test('2-03').should.be.false()
      SimpleDay.test('-2-03').should.be.false()
      done()

  describe 'Url', ->
    it 'should return true on valid urls', (done)->
      Url.test('http://yo.fr').should.be.true()
      Url.test('https://yo.fr').should.be.true()
      Url.test('https://yo.yo.fr').should.be.true()
      Url.test('https://y_o.yo.fr').should.be.true()
      Url.test('https://y-o.yo.fr').should.be.true()
      Url.test('https://hello:pwd@y-o.yo.holidays:3006').should.be.true()
      Url.test('https://hello:pwd@y-o.yo.holidays:3006/glou_-bi?q=boulga#yolo').should.be.true()
      done()

    it 'should return false on invalid urls', (done)->
      Url.test('nop').should.be.false()
      Url.test('yo.fr').should.be.false()
      Url.test('htp://yo.fr').should.be.false()
      Url.test('http//yo.fr').should.be.false()
      Url.test('https//yo.fr').should.be.false()
      Url.test('http:/yo.fr').should.be.false()
      Url.test('http:/yo.fr').should.be.false()
      Url.test('http://yo-.yo.fr').should.be.false()
      Url.test('http://yo_.yo.fr').should.be.false()
      Url.test('http://_yo.yo.fr').should.be.false()
      Url.test('http://yo._yo.fr').should.be.false()
      Url.test('/ipfs/Qme9GJd1UR3xDL4qofTvngBfV4kZpwzXD8VNVbg97d3qag').should.be.false()
      done()

  describe 'IpfsPath', ->
    it 'should return true on valid IPFS path', (done)->
      IpfsPath.test('/ipfs/Qme9GJd1UR3xDL4qofTvngBfV4kZpwzXD8VNVbg97d3qag').should.be.true()
      IpfsPath.test('/ipfs/notqmbutstillvalidTvngBfV4kZpwzXD8VNVbg97d3qag').should.be.true()
      done()

    it 'should return false on invalid IPFS path', (done)->
      IpfsPath.test('Qme9GJd1UR3xDL4qofTvngBfV4kZpwzXD8VNVbg97d3qag').should.be.false()
      done()
