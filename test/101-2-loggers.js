import should from 'should';
import _ from './utils_builder';

describe('Logger', function() {
  describe('log', function() {
    it('should return a string for string input', function(done){
      _.log('salut').should.be.a.String();
      _.log('ca va?', 'oui oui').should.be.a.String();
      return done();
    });

    return it('should return an object for object i nput', function(done){
      _.log({ ach: 'so' }).should.be.a.Object();
      _.log({ ya: 'klar' }, 'doh').should.be.a.Object();
      return done();
    });
  });

  describe('Log', () => it('should return _.log with a binded-label', function(done){
    const waitingLog = _.Log('hallo');
    waitingLog.should.be.a.Function();
    waitingLog({ hey: 'azegzagazere' });
    waitingLog({ hey: 'there' }).should.be.an.Object();
    return done();
  }));

  describe('warn', () => it('should always return undefined', function(done){
    should(_.warn('yo')).not.be.ok();
    should(_.warn('yo', { hello: 'wat' })).not.be.ok();
    should(_.warn({ hello: 'wat' }, 'yo')).not.be.ok();
    return done();
  }));

  describe('error', function() {
    it('should accept only error objects', function(done){
      should(() => _.error('yo')).throw();
      return done();
    });

    return it('should always return undefined', function(done){
      should(_.error(new Error('yo'))).not.be.ok();
      return done();
    });
  });

  describe('Error', () => it('should return an error logger that catches errors', function(done){
    should(_.Error('yo label')(new Error('yo'))).not.be.ok();

    Promise.reject(new Error('damned 1'))
    .catch(_.Error('catching!'))
    .then(() => done());
  }));

  return describe('ErrorRethrow', () => it('should return an error logger that rethrows errors', function(done){
    Promise.reject(new Error('damned 2'))
    .catch(_.ErrorRethrow('rethrowing!'))
    .catch(() => done());
    // should(_.ErrorRethrow('yo label')('yo')).not.be.ok()
    // should(_.ErrorRethrow('yo label')({hello: 'wat'})).not.be.ok()
  }));
});
