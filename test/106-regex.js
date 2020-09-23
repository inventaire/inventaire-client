import should from 'should';
import __ from '../root';
const { EntityUri, SimpleDay, ImageHash, Email } = __.require('lib', 'regex');

describe('Regex', function() {
  describe('EntityUri', function() {
    it('should be a regex', function(done){
      (EntityUri instanceof RegExp).should.be.true();
      return done();
    });

    it('should accept valid wikidata entities uri', function(done){
      EntityUri.test('wd:Q1').should.be.true();
      EntityUri.test('wd:Q1123').should.be.true();
      return done();
    });

    it('should reject invalid wikidata entities uri', function(done){
      EntityUri.test('Q1123').should.be.false();
      EntityUri.test('wd:P1123').should.be.false();
      EntityUri.test('wd:Q').should.be.false();
      return done();
    });

    it('should accept valid inventaire entities uri', function(done){
      EntityUri.test('inv:1234567890abcdef1234567890abcdef').should.be.true();
      return done();
    });

    it('should reject invalid inventaire entities uri', function(done){
      EntityUri.test('inv:1234567890abcdef1234567890abcde').should.be.false();
      EntityUri.test('inv:z234567890abcdef1234567890abcdef').should.be.false();
      EntityUri.test('inz:1234567890abcdef1234567890abcdef').should.be.false();
      EntityUri.test('1234567890abcdef1234567890abcdef').should.be.false();
      return done();
    });

    it('should accept valid isbn uri', function(done){
      EntityUri.test('isbn:9781231231231').should.be.true();
      EntityUri.test('isbn:1231231231').should.be.true();
      EntityUri.test('isbn:123123123X').should.be.true();
      return done();
    });

    return it('should reject invalid inventaire entities uri', function(done){
      EntityUri.test('isbn:978-123123123X').should.be.false();
      EntityUri.test('isbn:978123123123').should.be.false();
      EntityUri.test('isbn:97812312312').should.be.false();
      return done();
    });
  });

  describe('SimpleDay', function() {
    it('should accept a year alone', function(done){
      SimpleDay.test('1972').should.be.true();
      SimpleDay.test('972').should.be.true();
      SimpleDay.test('72').should.be.true();
      SimpleDay.test('2').should.be.true();
      SimpleDay.test('9972').should.be.true();
      SimpleDay.test('11972').should.be.false();
      return done();
    });

    it('should accept negative years', function(done){
      SimpleDay.test('-1972').should.be.true();
      SimpleDay.test('-972').should.be.true();
      SimpleDay.test('-72').should.be.true();
      SimpleDay.test('-2').should.be.true();
      return done();
    });

    it('should accept a day', function(done){
      SimpleDay.test('1972-01-01').should.be.true();
      SimpleDay.test('972-02-02').should.be.true();
      SimpleDay.test('72-03-03').should.be.true();
      SimpleDay.test('2-03-03').should.be.true();
      return done();
    });

    it('should accept a day in negative year', function(done){
      SimpleDay.test('-1972-01-01').should.be.true();
      SimpleDay.test('-972-02-02').should.be.true();
      SimpleDay.test('-72-03-03').should.be.true();
      SimpleDay.test('-2-03-03').should.be.true();
      return done();
    });

    it('should accept a year and month without a day', function(done){
      SimpleDay.test('1972-01').should.be.true();
      SimpleDay.test('-1972-01').should.be.true();
      SimpleDay.test('972-02').should.be.true();
      SimpleDay.test('-972-02').should.be.true();
      SimpleDay.test('72-03').should.be.true();
      SimpleDay.test('-72-03').should.be.true();
      SimpleDay.test('2-03').should.be.true();
      SimpleDay.test('-2-03').should.be.true();
      return done();
    });

    return it('should reject non-padded months or day', function(done){
      SimpleDay.test('1972-1-01').should.be.false();
      SimpleDay.test('1972-02-2').should.be.false();
      return done();
    });
  });

  describe('ImageHash', function() {
    it('should return true on valid image hash', function(done){
      ImageHash.test('ffd1a4dd8eec14d994ccf4a3bd372fb29fbe29f7').should.be.true();
      return done();
    });

    return it('should return false on invalid image hash', function(done){
      ImageHash.test('ffd1a4dd8eec14d994ccf4a3bd372fb29fbe29f').should.be.false();
      return done();
    });
  });

  return describe('Email', function() {
    it('should return true on valid email', function(done){
      Email.test('f@y.fr').should.be.true();
      Email.test('foo+bar@yolo.buzz.ninja').should.be.true();
      return done();
    });

    return it('should return false on invalid email', function(done){
      Email.test('foo@@bar.fr').should.be.false();
      return done();
    });
  });
});
