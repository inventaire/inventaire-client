global.window = global;
const _ = require('./utils_builder');
require('should');
const __ = require('../root');
const promisesUtils = __.require('lib', 'promises');
const undesiredRes = done => (function(res) {
  done(new Error('.then was not expected to be called'));
  return console.warn('undesired res', res);
});

describe('promises', function() {
  it('should not have additional enumerable keys', function(done){
    const promise = Promise.resolve();
    for (let key in promise) {
      const value = promise[key];
      throw new Error(`undesired enumerable key: ${key}`);
    }
    return done();
  });

  describe('try', function() {
    it('should be a function', function(done){
      Promise.try.should.be.a.Function();
      return done();
    });

    it('should return a resolved promise when passed a function not throwing', function(done){
      Promise.try(() => 'hello')
      .then(function(res){
        res.should.equal('hello');
        return done();}).catch(done);

    });

    return it('should return a rejected promise when passed a function throwing', function(done){
      Promise.try(function() { throw new Error('oh no'); })
      .then(undesiredRes(done))
      .catch(function(err){
        err.message.should.equal('oh no');
        return done();}).catch(done);

    });
  });

  describe('delay', function() {
    it('should be a function', function(done){
      Promise.prototype.delay.should.be.a.Function();
      return done();
    });

    it('should return delay the promise', function(done){
      const start = Date.now();
      Promise.try(() => 'hello')
      .delay(100)
      .then(function(res){
        const end = Date.now();
        should(end >= (start + 100)).be.true();
        should(end < (start + 110)).be.true();
        return done();}).catch(done);

    });

    return it('should not prevent the promise from rejecting', function(done){
      Promise.try(function() { throw new Error('oh no'); })
      .delay(100)
      .then(undesiredRes(done))
      .catch(function(err){
        err.message.should.equal('oh no');
        return done();}).catch(done);

    });
  });

  describe('props', function() {
    it('should be a function', function(done){
      Promise.props.should.be.a.Function();
      return done();
    });

    it('should return the resolved promise in an object', function(done){
      Promise.props({
        a: Promise.resolve(123),
        b: Promise.resolve(456)}).then(function(res){
        res.a.should.equal(123);
        res.b.should.equal(456);
        return done();}).catch(done);

    });

    it('should return a rejected promise if one of the promises fail', function(done){
      Promise.props({
        a: 123,
        b: Promise.reject(new Error('foo'))}).then(undesiredRes(done))
      .catch(function(err){
        err.message.should.equal('foo');
        return done();}).catch(done);

    });

    return it('should return direct values in an object', function(done){
      Promise.props({
        a: 1,
        b: 2}).then(function(res){
        res.a.should.equal(1);
        res.b.should.equal(2);
        return done();}).catch(done);

    });
  });

  describe('timeout', function() {
    it('should be a function', function(done){
      Promise.prototype.timeout.should.be.a.Function();
      return done();
    });

    it('should reject a promise after the timeout expired', function(done){
      Promise.resolve('hello')
      .delay(100)
      .timeout(10)
      .then(undesiredRes(done))
      .catch(function(err){
        err.name.should.equal('TimeoutError');
        err.message.should.equal('operation timed out');
        return done();
      });

    });

    return it('should reject the original error', function(done){
      Promise.reject(new Error('hello'))
      .timeout(10)
      .then(undesiredRes(done))
      .catch(function(err){
        err.message.should.equal('hello');
        return done();
      });

    });
  });

  describe('spread', function() {
    it('should be a function', function(done){
      Promise.prototype.spread.should.be.a.Function();
      return done();
    });

    it('should spread results', function(done){
      Promise.resolve([ 1, 2 ])
      .spread(function(a, b){
        a.should.equal(1);
        b.should.equal(2);
        return done();}).catch(done);

    });

    return it('should pass errors', function(done){
      Promise.all([
        Promise.resolve(123),
        Promise.reject(new Error('hello'))
      ])
      .spread(undesiredRes(done))
      .catch(function(err){
        err.message.should.equal('hello');
        return done();}).catch(done);

    });
  });

  describe('get', function() {
    it('should be a function', function(done){
      Promise.prototype.get.should.be.a.Function();
      return done();
    });

    it('should get the result attribute', function(done){
      Promise.resolve({ a: 1, b: 2 })
      .get('b')
      .then(function(res){
        res.should.equal(2);
        return done();}).catch(done);

    });

    return it('should pass errors', function(done){
      Promise.reject(new Error('hello'))
      .get('foo')
      .then(undesiredRes(done))
      .catch(function(err){
        err.message.should.equal('hello');
        return done();}).catch(done);

    });
  });

  describe('tap', function() {
    it('should be a function', function(done){
      Promise.prototype.tap.should.be.a.Function();
      return done();
    });

    it('should not alter the passed result', function(done){
      Promise.resolve({ a: 1, b: 2 })
      .tap(function(res){
        res.a.should.equal(1);
        res.b.should.equal(2);
        }).then(function(res){
        res.a.should.equal(1);
        res.b.should.equal(2);
        return done();}).catch(done);

    });

    it('should pass errors', function(done){
      Promise.reject(new Error('hello'))
      .tap(undesiredRes(done))
      .catch(function(err){
        err.message.should.equal('hello');
        return done();}).catch(done);

    });

    return it('should not fail silently', function(done){
      Promise.resolve({ a: 1, b: 2 })
      .tap(function(res){ throw new Error('oh no'); })
      .then(undesiredRes(done))
      .catch(function(err){
        err.message.should.equal('oh no');
        return done();}).catch(done);

    });
  });

  describe('finally', function() {
    it('should be a function', function(done){
      Promise.prototype.finally.should.be.a.Function();
      return done();
    });

    it('should not be provided any argument after a resolved promise', function(done){
      Promise.resolve()
      .finally(function(...args){
        args.should.deepEqual([]);
        return done();}).catch(done);

    });

    it('should not be provided any argument after a rejected promise', function(done){
      let called = false;
      Promise.reject(new Error('foo'))
      .finally(function(...args){
        called = true;
        return args.should.deepEqual([]);})
      .catch(function(err){
        called.should.be.true();
        return done();}).catch(done);

    });

    it('should pass the resolved value', function(done){
      Promise.resolve(123)
      .finally(() => 456)
      .then(function(res){
        res.should.equal(123);
        return done();}).catch(done);

    });

    it('should pass the rejected error', function(done){
      Promise.reject(new Error('foo'))
      .finally(() => 456)
      .catch(function(err){
        err.message.should.equal('foo');
        return done();}).catch(done);

    });

    return it('should be called only once', function(done){
      let counter = 0;
      Promise.resolve()
      .finally(function() {
        counter++;
        throw new Error('foo');}).catch(function(err){
        err.message.should.equal('foo');
        counter.should.equal(1);
        return done();}).catch(done);

    });
  });

  describe('filter', function() {
    it('should be a function', function(done){
      Promise.prototype.filter.should.be.a.Function();
      return done();
    });

    it('should filter results', function(done){
      Promise.all([
        1,
        2,
        Promise.resolve(3)
      ])
      .filter(num => num > 1)
      .then(function(res){
        res.should.deepEqual([ 2, 3 ]);
        return done();}).catch(done);

    });

    it('should filter results from an array containing promises', function(done){
      Promise.resolve([
        1,
        2,
        Promise.resolve(3)
      ])
      .filter(num => num > 1)
      .then(function(res){
        res.should.deepEqual([ 2, 3 ]);
        return done();}).catch(done);

    });

    return it('should pass errors', function(done){
      Promise.all([
        Promise.resolve(123),
        Promise.reject(new Error('hello'))
      ])
      .filter(undesiredRes(done))
      .catch(function(err){
        err.message.should.equal('hello');
        return done();}).catch(done);

    });
  });

  describe('map', function() {
    it('should be a function', function(done){
      Promise.prototype.map.should.be.a.Function();
      return done();
    });

    it('should map results', function(done){
      Promise.all([
        1,
        2,
        Promise.resolve(3)
      ])
      .map(num => num * 2)
      .then(function(res){
        res.should.deepEqual([ 2, 4, 6 ]);
        return done();}).catch(done);

    });

    it('should map results from an array containing promises', function(done){
      Promise.resolve([
        1,
        2,
        Promise.resolve(3)
      ])
      .map(num => num * 2)
      .then(function(res){
        res.should.deepEqual([ 2, 4, 6 ]);
        return done();}).catch(done);

    });

    it('should map return resolved values', function(done){
      Promise.resolve([ 1, 2, 3 ])
      .map(num => Promise.resolve(num * 2))
      .then(function(res){
        res.should.deepEqual([ 2, 4, 6 ]);
        return done();}).catch(done);

    });

    return it('should pass errors', function(done){
      Promise.resolve([
        Promise.resolve(123),
        Promise.reject(new Error('hello'))
      ])
      .map(undesiredRes(done))
      .catch(function(err){
        err.message.should.equal('hello');
        return done();}).catch(done);

    });
  });

  return describe('reduce', function() {
    it('should be a function', function(done){
      Promise.prototype.reduce.should.be.a.Function();
      return done();
    });

    it('should reduce results', function(done){
      const sum = (a, b) => a + b;
      Promise.resolve([
        1,
        2,
        Promise.resolve(3)
      ])
      .reduce(sum, 5)
      .then(function(res){
        res.should.equal(11);
        return done();}).catch(done);

    });

    it('should reduce results from an array containing promises', function(done){
      const sum = (a, b) => a + b;
      Promise.all([
        1,
        2,
        Promise.resolve(3)
      ])
      .reduce(sum, 5)
      .then(function(res){
        res.should.equal(11);
        return done();}).catch(done);

    });

    return it('should pass errors', function(done){
      Promise.all([
        Promise.resolve(123),
        Promise.reject(new Error('hello'))
      ])
      .reduce(undesiredRes(done))
      .catch(function(err){
        err.message.should.equal('hello');
        return done();}).catch(done);

    });
  });
});
