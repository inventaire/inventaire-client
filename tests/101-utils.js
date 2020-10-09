import 'should'
import { typeOf, forceArray, cutBeforeWord } from 'lib/utils'

describe('utils', () => {
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

  describe('forceArray', () => {
    it('should return an array for an array', () => {
      const a = forceArray([ 1, 2, 3, { zo: 'hello' }, null ])
      a.should.be.an.Array()
      a.length.should.equal(5)
    })

    it('should return an array for a string', () => {
      const a = forceArray('yolo')
      a.should.be.an.Array()
      a.length.should.equal(1)
    })

    it('should return an array for a number', () => {
      const a = forceArray(125)
      a.should.be.an.Array()
      a.length.should.equal(1)
      const b = forceArray(-12612125)
      b.should.be.an.Array()
      b.length.should.equal(1)
    })

    it('should return an array for an object', () => {
      const a = forceArray({ bon: 'jour' })
      a.should.be.an.Array()
      a.length.should.equal(1)
    })

    it('should return an empty array for null', () => {
      const a = forceArray(null)
      a.should.be.an.Array()
      a.length.should.equal(0)
    })

    it('should return an empty array for undefined', () => {
      const a = forceArray(null)
      a.should.be.an.Array()
      a.length.should.equal(0)
    })

    it('should return an empty array for an empty input', () => {
      const a = forceArray()
      a.should.be.an.Array()
      a.length.should.equal(0)
    })

    it('should return an empty array for an empty string', () => {
      const a = forceArray('')
      a.should.be.an.Array()
      a.length.should.equal(0)
    })
  })

  describe('cutBeforeWord', () => {
    const text = 'Lorem ipsum dolor sit amet, consectetur adipisicing elit'
    const result = cutBeforeWord(text, 24)

    it('should return a string shorter or egal to the limit', () => {
      (result.length <= 24).should.equal(true)
    })

    it('should cut between words', () => {
      result.should.equal('Lorem ipsum dolor sit')
    })
  })
})
