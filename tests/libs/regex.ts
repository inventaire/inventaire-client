import 'should'
import { EntityUri, SimpleDay, ImageHash, Email } from '#app/lib/regex'

describe('Regex', () => {
  describe('EntityUri', () => {
    it('should be a regex', () => {
      (EntityUri instanceof RegExp).should.be.true()
    })

    it('should accept valid wikidata entities uri', () => {
      EntityUri.test('wd:Q1').should.be.true()
      EntityUri.test('wd:Q1123').should.be.true()
    })

    it('should reject invalid wikidata entities uri', () => {
      EntityUri.test('Q1123').should.be.false()
      EntityUri.test('wd:P1123').should.be.false()
      EntityUri.test('wd:Q').should.be.false()
    })

    it('should accept valid inventaire entities uri', () => {
      EntityUri.test('inv:1234567890abcdef1234567890abcdef').should.be.true()
    })

    it('should reject invalid inventaire entities uri', () => {
      EntityUri.test('inv:1234567890abcdef1234567890abcde').should.be.false()
      EntityUri.test('inv:z234567890abcdef1234567890abcdef').should.be.false()
      EntityUri.test('inz:1234567890abcdef1234567890abcdef').should.be.false()
      EntityUri.test('1234567890abcdef1234567890abcdef').should.be.false()
    })

    it('should accept valid isbn uri', () => {
      EntityUri.test('isbn:9781231231231').should.be.true()
      EntityUri.test('isbn:1231231231').should.be.true()
      EntityUri.test('isbn:123123123X').should.be.true()
    })

    it('should reject invalid inventaire entities uri', () => {
      EntityUri.test('isbn:978-123123123X').should.be.false()
      EntityUri.test('isbn:978123123123').should.be.false()
      EntityUri.test('isbn:97812312312').should.be.false()
    })
  })

  describe('SimpleDay', () => {
    it('should accept a year alone', () => {
      SimpleDay.test('1972').should.be.true()
      SimpleDay.test('972').should.be.true()
      SimpleDay.test('72').should.be.true()
      SimpleDay.test('2').should.be.true()
      SimpleDay.test('9972').should.be.true()
      SimpleDay.test('11972').should.be.false()
    })

    it('should accept negative years', () => {
      SimpleDay.test('-1972').should.be.true()
      SimpleDay.test('-972').should.be.true()
      SimpleDay.test('-72').should.be.true()
      SimpleDay.test('-2').should.be.true()
    })

    it('should accept a day', () => {
      SimpleDay.test('1972-01-01').should.be.true()
      SimpleDay.test('972-02-02').should.be.true()
      SimpleDay.test('72-03-03').should.be.true()
      SimpleDay.test('2-03-03').should.be.true()
    })

    it('should accept a day in negative year', () => {
      SimpleDay.test('-1972-01-01').should.be.true()
      SimpleDay.test('-972-02-02').should.be.true()
      SimpleDay.test('-72-03-03').should.be.true()
      SimpleDay.test('-2-03-03').should.be.true()
    })

    it('should accept a year and month without a day', () => {
      SimpleDay.test('1972-01').should.be.true()
      SimpleDay.test('-1972-01').should.be.true()
      SimpleDay.test('972-02').should.be.true()
      SimpleDay.test('-972-02').should.be.true()
      SimpleDay.test('72-03').should.be.true()
      SimpleDay.test('-72-03').should.be.true()
      SimpleDay.test('2-03').should.be.true()
      SimpleDay.test('-2-03').should.be.true()
    })

    it('should reject non-padded months or day', () => {
      SimpleDay.test('1972-1-01').should.be.false()
      SimpleDay.test('1972-02-2').should.be.false()
    })
  })

  describe('ImageHash', () => {
    it('should return true on valid image hash', () => {
      ImageHash.test('ffd1a4dd8eec14d994ccf4a3bd372fb29fbe29f7').should.be.true()
    })

    it('should return false on invalid image hash', () => {
      ImageHash.test('ffd1a4dd8eec14d994ccf4a3bd372fb29fbe29f').should.be.false()
    })
  })

  describe('Email', () => {
    it('should return true on valid email', () => {
      Email.test('f@y.fr').should.be.true()
      Email.test('foo+bar@yolo.buzz.ninja').should.be.true()
    })

    it('should return false on invalid email', () => {
      Email.test('foo@@bar.fr').should.be.false()
    })
  })
})
