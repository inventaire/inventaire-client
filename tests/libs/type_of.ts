import 'should'
import typeOf from '#app/lib/type_of'

describe('typeOf', () => {
  it('should return the right type', () => {
    typeOf('hello').should.equal('string')
    typeOf([ 'hello' ]).should.equal('array')
    typeOf({ hel: 'lo' }).should.equal('object')
    typeOf(83110).should.equal('number')
    typeOf(null).should.equal('null')
    typeOf().should.equal('undefined')
    typeOf(false).should.equal('boolean')
    typeOf(Number('boudu')).should.equal('NaN')
  })
})
