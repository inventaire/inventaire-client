import should from 'should'
import { tryAsync, tap, props as promiseProps, waitForAttribute, wait } from '#app/lib/promises'
import { shouldNotBeCalled } from '#client/tests/utils/utils'

const undesiredRes = res => {
  console.warn('undesired res', res)
  throw new Error('.then was not expected to be called')
}

describe('promises', () => {
  describe('tryAsync', () => {
    it('should be a function', () => {
      tryAsync.should.be.a.Function()
    })

    it('should return a resolved promise when passed a function not throwing', async () => {
      const res = await tryAsync(() => 'hello')
      res.should.equal('hello')
    })

    it('should return a rejected promise when passed a function throwing', async () => {
      await tryAsync(() => { throw new Error('oh no') })
      .then(undesiredRes)
      .catch(err => {
        err.message.should.equal('oh no')
      })
    })
  })

  describe('props', () => {
    it('should be a function', () => {
      promiseProps.should.be.a.Function()
    })

    it('should return the resolved promise in an object', async () => {
      const res = await promiseProps({
        a: Promise.resolve(123),
        b: Promise.resolve(456),
      })
      res.a.should.equal(123)
      res.b.should.equal(456)
    })

    it('should return a rejected promise if one of the promises fail', async () => {
      await promiseProps({
        a: 123,
        b: Promise.reject(new Error('foo')),
      })
      .then(undesiredRes)
      .catch(err => {
        err.message.should.equal('foo')
      })
    })

    it('should return direct values in an object', async () => {
      const res = await promiseProps({
        a: 1,
        b: 2,
      })
      res.a.should.equal(1)
      res.b.should.equal(2)
    })
  })

  describe('tap', () => {
    it('should be a function', () => {
      tap.should.be.a.Function()
    })

    it('should not alter the passed result', async () => {
      await Promise.resolve({ a: 1, b: 2 })
      .then(tap(res => {
        res.a.should.equal(1)
        res.b.should.equal(2)
      }))
      .then(res => {
        res.a.should.equal(1)
        res.b.should.equal(2)
      })
    })

    it('should pass errors', async () => {
      await Promise.reject(new Error('hello'))
      .then(tap(undesiredRes))
      .catch(err => {
        err.message.should.equal('hello')
      })
    })

    it('should not fail silently', async () => {
      await Promise.resolve({ a: 1, b: 2 })
      .then(tap(() => { throw new Error('oh no') }))
      .then(undesiredRes)
      .catch(err => {
        err.message.should.equal('oh no')
      })
    })
  })

  describe('waitForAttribute', () => {
    it('should wait for an attribute to be defined to resolve', async () => {
      const obj = { a: undefined }
      setTimeout(() => { obj.a = 123 }, 20)
      should(obj.a).not.be.ok()
      const a = await waitForAttribute(obj, 'a')
      a.should.equal(123)
    })

    it('should wait for the attribute to resolve', async () => {
      const obj = {
        waitForA: wait(30).then(() => 123),
      }
      const a = await waitForAttribute(obj, 'waitForA')
      a.should.equal(123)
    })

    it('should reject if not passed an object', async () => {
      await waitForAttribute(null, 'waitForA')
      .then(shouldNotBeCalled)
      .catch(err => {
        err.name.should.equal('Error')
      })
    })

    it('should accept null values', async () => {
      const obj = { a: undefined }
      setTimeout(() => { obj.a = null }, 20)
      should(obj.a).not.be.ok()
      const a = await waitForAttribute(obj, 'a')
      should(a).be.Null()
    })

    it('should stop waiting after a certain number of attempts', async () => {
      await waitForAttribute({}, 'a', { attemptTimeout: 10, maxAttempts: 5 })
      .then(shouldNotBeCalled)
      .catch(err => {
        err.message.should.equal('too many attempts')
        err.name.should.equal('waitForAttributeError')
      })
    })
  })
})
