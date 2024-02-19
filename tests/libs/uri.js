import should from 'should'
import findUri from '#modules/search/lib/find_uri'

describe('findUri', () => {
  it('should find a wikidata uri', () => {
    findUri('q1').should.equal('wd:Q1')
    findUri('Q1').should.equal('wd:Q1')
    findUri('wd:Q1').should.equal('wd:Q1')
    findUri('wd:q1').should.equal('wd:Q1')
  })

  it('should find an inv uri', () => {
    const uri = 'inv:e7ecbb0a797eabca4e1706b33a000c71'
    findUri(uri).should.equal(uri)
  })

  it('should find an isbn uri', () => {
    findUri('9780552167741').should.equal('isbn:9780552167741')
    findUri('978-0-552-16774-1').should.equal('isbn:9780552167741')
    findUri('978-0552167741').should.equal('isbn:9780552167741')
    findUri('0-552-16774-6').should.equal('isbn:0552167746')
    findUri('0552167746').should.equal('isbn:0552167746')
    findUri('isbn:9780552167741').should.equal('isbn:9780552167741')
  })

  it('should return nothing for non-uri', () => {
    should(findUri('foo')).not.be.ok()
    should(findUri('p1')).not.be.ok()
    should(findUri('azQ123')).not.be.ok()
  })
})
