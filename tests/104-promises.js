import should from 'should'
import { tryAsync, tap, props as promiseProps, waitForAttribute, wait } from '#lib/promises'

global.window = global
const undesiredRes = done => res => {
  done(new Error('.then was not expected to be called'))
  console.warn('undesired res', res)
}

describe('promises', () => {
  describe('tryAsync', () => {
    it('should be a function', done => {
      tryAsync.should.be.a.Function()
      done()
    })

    it('should return a resolved promise when passed a function not throwing', done => {
      tryAsync(() => 'hello')
      .then(res => {
        res.should.equal('hello')
        done()
      })
      .catch(done)
    })

    it('should return a rejected promise when passed a function throwing', done => {
      tryAsync(() => { throw new Error('oh no') })
      .then(undesiredRes(done))
      .catch(err => {
        err.message.should.equal('oh no')
        done()
      })
      .catch(done)
    })
  })

  describe('props', () => {
    it('should be a function', done => {
      promiseProps.should.be.a.Function()
      done()
    })

    it('should return the resolved promise in an object', done => {
      promiseProps({
        a: Promise.resolve(123),
        b: Promise.resolve(456)
      })
      .then(res => {
        res.a.should.equal(123)
        res.b.should.equal(456)
        done()
      })
      .catch(done)
    })

    it('should return a rejected promise if one of the promises fail', done => {
      promiseProps({
        a: 123,
        b: Promise.reject(new Error('foo'))
      })
      .then(undesiredRes(done))
      .catch(err => {
        err.message.should.equal('foo')
        done()
      })
      .catch(done)
    })

    it('should return direct values in an object', done => {
      promiseProps({
        a: 1,
        b: 2
      })
      .then(res => {
        res.a.should.equal(1)
        res.b.should.equal(2)
        done()
      })
      .catch(done)
    })
  })

  describe('tap', () => {
    it('should be a function', done => {
      tap.should.be.a.Function()
      done()
    })

    it('should not alter the passed result', done => {
      Promise.resolve({ a: 1, b: 2 })
      .then(tap(res => {
        res.a.should.equal(1)
        res.b.should.equal(2)
      }))
      .then(res => {
        res.a.should.equal(1)
        res.b.should.equal(2)
        done()
      })
      .catch(done)
    })

    it('should pass errors', done => {
      Promise.reject(new Error('hello'))
      .then(tap(undesiredRes(done)))
      .catch(err => {
        err.message.should.equal('hello')
        done()
      })
      .catch(done)
    })

    it('should not fail silently', done => {
      Promise.resolve({ a: 1, b: 2 })
      .then(tap(() => { throw new Error('oh no') }))
      .then(undesiredRes(done))
      .catch(err => {
        err.message.should.equal('oh no')
        done()
      })
      .catch(done)
    })
  })

  describe('waitForAttribute', () => {
    it('should wait for an attribute to be defined to resolve', async () => {
      const obj = {}
      setTimeout(() => { obj.a = 123 }, 20)
      should(obj.a).not.be.ok()
      const a = await waitForAttribute(obj, 'a')
      a.should.equal(123)
    })

    it('should wait for the attribute to resolve', async () => {
      const obj = {}
      obj.waitForA = wait(30).then(() => 123)
      const a = await waitForAttribute(obj, 'waitForA')
      a.should.equal(123)
    })
  })
})
