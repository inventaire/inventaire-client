import 'should'
import findUri from '#modules/search/lib/find_uri'

describe('findUri', () => {
  it('should find a wikidata uri', () => {
    findUri('q1').should.equal('wd:Q1')
    findUri('Q1').should.equal('wd:Q1')
    findUri('wd:Q1').should.equal('wd:Q1')
    findUri('wd:q1').should.equal('wd:Q1')
  })
})
