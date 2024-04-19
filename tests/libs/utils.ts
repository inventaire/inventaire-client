import 'should'
import { forceArray, cutBeforeWord } from '#app/lib/utils'

describe('utils', () => {
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

    it('should return a string shorter or egal to the limit', () => {
      (cutBeforeWord(text, 24).length <= 24).should.equal(true)
    })

    it('should cut between words', () => {
      cutBeforeWord(text, 24).should.equal('Lorem ipsum dolor sit')
    })

    it('should not cut below limit', () => {
      cutBeforeWord(text, 100).should.equal(text)
    })
  })
})
