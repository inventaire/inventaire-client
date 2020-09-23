/* eslint-disable
    handle-callback-err,
    no-undef,
    no-unused-vars,
    prefer-arrow/prefer-arrow-functions,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
global.window = global
const _ = require('./utils_builder')
require('should')
const __ = require('../root')
const promisesUtils = __.require('lib', 'promises')
const undesiredRes = done => function (res) {
  done(new Error('.then was not expected to be called'))
  return console.warn('undesired res', res)
}

describe('promises', () => {
  it('should not have additional enumerable keys', done => {
    const promise = Promise.resolve()
    for (const key in promise) {
      const value = promise[key]
      throw new Error(`undesired enumerable key: ${key}`)
    }
    return done()
  })

  describe('try', () => {
    it('should be a function', done => {
      Promise.try.should.be.a.Function()
      return done()
    })

    it('should return a resolved promise when passed a function not throwing', done => {
      Promise.try(() => 'hello')
      .then(res => {
        res.should.equal('hello')
        return done()
      }).catch(done)
    })

    return it('should return a rejected promise when passed a function throwing', done => {
      Promise.try(() => { throw new Error('oh no') })
      .then(undesiredRes(done))
      .catch(err => {
        err.message.should.equal('oh no')
        return done()
      }).catch(done)
    })
  })

  describe('delay', () => {
    it('should be a function', done => {
      Promise.prototype.delay.should.be.a.Function()
      return done()
    })

    it('should return delay the promise', done => {
      const start = Date.now()
      Promise.try(() => 'hello')
      .delay(100)
      .then(res => {
        const end = Date.now()
        should(end >= (start + 100)).be.true()
        should(end < (start + 110)).be.true()
        return done()
      }).catch(done)
    })

    return it('should not prevent the promise from rejecting', done => {
      Promise.try(() => { throw new Error('oh no') })
      .delay(100)
      .then(undesiredRes(done))
      .catch(err => {
        err.message.should.equal('oh no')
        return done()
      }).catch(done)
    })
  })

  describe('props', () => {
    it('should be a function', done => {
      Promise.props.should.be.a.Function()
      return done()
    })

    it('should return the resolved promise in an object', done => {
      Promise.props({
        a: Promise.resolve(123),
        b: Promise.resolve(456)
      }).then(res => {
        res.a.should.equal(123)
        res.b.should.equal(456)
        return done()
      }).catch(done)
    })

    it('should return a rejected promise if one of the promises fail', done => {
      Promise.props({
        a: 123,
        b: Promise.reject(new Error('foo'))
      }).then(undesiredRes(done))
      .catch(err => {
        err.message.should.equal('foo')
        return done()
      }).catch(done)
    })

    return it('should return direct values in an object', done => {
      Promise.props({
        a: 1,
        b: 2
      }).then(res => {
        res.a.should.equal(1)
        res.b.should.equal(2)
        return done()
      }).catch(done)
    })
  })

  describe('timeout', () => {
    it('should be a function', done => {
      Promise.prototype.timeout.should.be.a.Function()
      return done()
    })

    it('should reject a promise after the timeout expired', done => {
      Promise.resolve('hello')
      .delay(100)
      .timeout(10)
      .then(undesiredRes(done))
      .catch(err => {
        err.name.should.equal('TimeoutError')
        err.message.should.equal('operation timed out')
        return done()
      })
    })

    return it('should reject the original error', done => {
      Promise.reject(new Error('hello'))
      .timeout(10)
      .then(undesiredRes(done))
      .catch(err => {
        err.message.should.equal('hello')
        return done()
      })
    })
  })

  describe('spread', () => {
    it('should be a function', done => {
      Promise.prototype.spread.should.be.a.Function()
      return done()
    })

    it('should spread results', done => {
      Promise.resolve([ 1, 2 ])
      .spread((a, b) => {
        a.should.equal(1)
        b.should.equal(2)
        return done()
      }).catch(done)
    })

    return it('should pass errors', done => {
      Promise.all([
        Promise.resolve(123),
        Promise.reject(new Error('hello'))
      ])
      .spread(undesiredRes(done))
      .catch(err => {
        err.message.should.equal('hello')
        return done()
      }).catch(done)
    })
  })

  describe('get', () => {
    it('should be a function', done => {
      Promise.prototype.get.should.be.a.Function()
      return done()
    })

    it('should get the result attribute', done => {
      Promise.resolve({ a: 1, b: 2 })
      .get('b')
      .then(res => {
        res.should.equal(2)
        return done()
      }).catch(done)
    })

    return it('should pass errors', done => {
      Promise.reject(new Error('hello'))
      .get('foo')
      .then(undesiredRes(done))
      .catch(err => {
        err.message.should.equal('hello')
        return done()
      }).catch(done)
    })
  })

  describe('tap', () => {
    it('should be a function', done => {
      Promise.prototype.tap.should.be.a.Function()
      return done()
    })

    it('should not alter the passed result', done => {
      Promise.resolve({ a: 1, b: 2 })
      .tap(res => {
        res.a.should.equal(1)
        res.b.should.equal(2)
      }).then(res => {
        res.a.should.equal(1)
        res.b.should.equal(2)
        return done()
      }).catch(done)
    })

    it('should pass errors', done => {
      Promise.reject(new Error('hello'))
      .tap(undesiredRes(done))
      .catch(err => {
        err.message.should.equal('hello')
        return done()
      }).catch(done)
    })

    return it('should not fail silently', done => {
      Promise.resolve({ a: 1, b: 2 })
      .tap(res => { throw new Error('oh no') })
      .then(undesiredRes(done))
      .catch(err => {
        err.message.should.equal('oh no')
        return done()
      }).catch(done)
    })
  })

  describe('finally', () => {
    it('should be a function', done => {
      Promise.prototype.finally.should.be.a.Function()
      return done()
    })

    it('should not be provided any argument after a resolved promise', done => {
      Promise.resolve()
      .finally((...args) => {
        args.should.deepEqual([])
        return done()
      }).catch(done)
    })

    it('should not be provided any argument after a rejected promise', done => {
      let called = false
      Promise.reject(new Error('foo'))
      .finally((...args) => {
        called = true
        return args.should.deepEqual([])
      })
      .catch(err => {
        called.should.be.true()
        return done()
      }).catch(done)
    })

    it('should pass the resolved value', done => {
      Promise.resolve(123)
      .finally(() => 456)
      .then(res => {
        res.should.equal(123)
        return done()
      }).catch(done)
    })

    it('should pass the rejected error', done => {
      Promise.reject(new Error('foo'))
      .finally(() => 456)
      .catch(err => {
        err.message.should.equal('foo')
        return done()
      }).catch(done)
    })

    return it('should be called only once', done => {
      let counter = 0
      Promise.resolve()
      .finally(() => {
        counter++
        throw new Error('foo')
      }).catch(err => {
        err.message.should.equal('foo')
        counter.should.equal(1)
        return done()
      }).catch(done)
    })
  })

  describe('filter', () => {
    it('should be a function', done => {
      Promise.prototype.filter.should.be.a.Function()
      return done()
    })

    it('should filter results', done => {
      Promise.all([
        1,
        2,
        Promise.resolve(3)
      ])
      .filter(num => num > 1)
      .then(res => {
        res.should.deepEqual([ 2, 3 ])
        return done()
      }).catch(done)
    })

    it('should filter results from an array containing promises', done => {
      Promise.resolve([
        1,
        2,
        Promise.resolve(3)
      ])
      .filter(num => num > 1)
      .then(res => {
        res.should.deepEqual([ 2, 3 ])
        return done()
      }).catch(done)
    })

    return it('should pass errors', done => {
      Promise.all([
        Promise.resolve(123),
        Promise.reject(new Error('hello'))
      ])
      .filter(undesiredRes(done))
      .catch(err => {
        err.message.should.equal('hello')
        return done()
      }).catch(done)
    })
  })

  describe('map', () => {
    it('should be a function', done => {
      Promise.prototype.map.should.be.a.Function()
      return done()
    })

    it('should map results', done => {
      Promise.all([
        1,
        2,
        Promise.resolve(3)
      ])
      .map(num => num * 2)
      .then(res => {
        res.should.deepEqual([ 2, 4, 6 ])
        return done()
      }).catch(done)
    })

    it('should map results from an array containing promises', done => {
      Promise.resolve([
        1,
        2,
        Promise.resolve(3)
      ])
      .map(num => num * 2)
      .then(res => {
        res.should.deepEqual([ 2, 4, 6 ])
        return done()
      }).catch(done)
    })

    it('should map return resolved values', done => {
      Promise.resolve([ 1, 2, 3 ])
      .map(num => Promise.resolve(num * 2))
      .then(res => {
        res.should.deepEqual([ 2, 4, 6 ])
        return done()
      }).catch(done)
    })

    return it('should pass errors', done => {
      Promise.resolve([
        Promise.resolve(123),
        Promise.reject(new Error('hello'))
      ])
      .map(undesiredRes(done))
      .catch(err => {
        err.message.should.equal('hello')
        return done()
      }).catch(done)
    })
  })

  return describe('reduce', () => {
    it('should be a function', done => {
      Promise.prototype.reduce.should.be.a.Function()
      return done()
    })

    it('should reduce results', done => {
      const sum = (a, b) => a + b
      Promise.resolve([
        1,
        2,
        Promise.resolve(3)
      ])
      .reduce(sum, 5)
      .then(res => {
        res.should.equal(11)
        return done()
      }).catch(done)
    })

    it('should reduce results from an array containing promises', done => {
      const sum = (a, b) => a + b
      Promise.all([
        1,
        2,
        Promise.resolve(3)
      ])
      .reduce(sum, 5)
      .then(res => {
        res.should.equal(11)
        return done()
      }).catch(done)
    })

    return it('should pass errors', done => {
      Promise.all([
        Promise.resolve(123),
        Promise.reject(new Error('hello'))
      ])
      .reduce(undesiredRes(done))
      .catch(err => {
        err.message.should.equal('hello')
        return done()
      }).catch(done)
    })
  })
})
