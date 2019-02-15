global.window = global
_ = require './utils_builder'
require 'should'
__ = require '../root'
promisesUtils = __.require 'lib', 'promises'
undesiredRes = (done)-> (res)->
  done new Error('.then was not expected to be called')
  console.warn('undesired res', res)

describe 'promises', ->
  describe 'try', ->
    it 'should be a function', (done)->
      Promise.try.should.be.a.Function()
      done()

    it 'should return a resolved promise when passed a function not throwing', (done)->
      Promise.try -> 'hello'
      .then (res)->
        res.should.equal 'hello'
        done()
      .catch done

      return

    it 'should return a rejected promise when passed a function throwing', (done)->
      Promise.try -> throw new Error 'oh no'
      .then undesiredRes(done)
      .catch (err)->
        err.message.should.equal 'oh no'
        done()
      .catch done

      return

  describe 'delay', ->
    it 'should be a function', (done)->
      Promise::delay.should.be.a.Function()
      done()

    it 'should return delay the promise', (done)->
      start = Date.now()
      Promise.try -> 'hello'
      .delay 100
      .then (res)->
        end = Date.now()
        should(end >= start + 100).be.true()
        should(end < start + 110).be.true()
        done()
      .catch done

      return

    it 'should not prevent the promise from rejecting', (done)->
      Promise.try -> throw new Error 'oh no'
      .delay 100
      .then undesiredRes(done)
      .catch (err)->
        err.message.should.equal 'oh no'
        done()
      .catch done

      return

  describe 'props', ->
    it 'should be a function', (done)->
      Promise.props.should.be.a.Function()
      done()

    it 'should return the resolved promise in an object', (done)->
      Promise.props
        a: Promise.resolve 123
        b: Promise.resolve 456
      .then (res)->
        res.a.should.equal 123
        res.b.should.equal 456
        done()
      .catch done

      return

    it 'should return a rejected promise if one of the promises fail', (done)->
      Promise.props
        a: 123
        b: Promise.reject new Error('foo')
      .then undesiredRes(done)
      .catch (err)->
        err.message.should.equal 'foo'
        done()
      .catch done

      return

    it 'should return direct values in an object', (done)->
      Promise.props
        a: 1
        b: 2
      .then (res)->
        res.a.should.equal 1
        res.b.should.equal 2
        done()
      .catch done

      return

  describe 'timeout', ->
    it 'should be a function', (done)->
      Promise::timeout.should.be.a.Function()
      done()

    it 'should reject a promise after the timeout expired', (done)->
      Promise.resolve 'hello'
      .delay 100
      .timeout 10
      .then undesiredRes(done)
      .catch (err)->
        err.name.should.equal 'TimeoutError'
        err.message.should.equal 'operation timed out'
        done()

      return

    it 'should reject the original error', (done)->
      Promise.reject new Error('hello')
      .timeout 10
      .then undesiredRes(done)
      .catch (err)->
        err.message.should.equal 'hello'
        done()

      return

  describe 'spread', ->
    it 'should be a function', (done)->
      Promise::spread.should.be.a.Function()
      done()

    it 'should spread results', (done)->
      Promise.resolve [ 1, 2 ]
      .spread (a, b)->
        a.should.equal 1
        b.should.equal 2
        done()
      .catch done

      return

    it 'should pass errors', (done)->
      Promise.all [
        Promise.resolve 123
        Promise.reject new Error('hello')
      ]
      .spread undesiredRes(done)
      .catch (err)->
        err.message.should.equal 'hello'
        done()
      .catch done

      return

  describe 'get', ->
    it 'should be a function', (done)->
      Promise::get.should.be.a.Function()
      done()

    it 'should get the result attribute', (done)->
      Promise.resolve { a: 1, b: 2 }
      .get 'b'
      .then (res)->
        res.should.equal 2
        done()
      .catch done

      return

    it 'should pass errors', (done)->
      Promise.reject new Error('hello')
      .get 'foo'
      .then undesiredRes(done)
      .catch (err)->
        err.message.should.equal 'hello'
        done()
      .catch done

      return

  describe 'tap', ->
    it 'should be a function', (done)->
      Promise::tap.should.be.a.Function()
      done()

    it 'should not alter the passed result', (done)->
      Promise.resolve { a: 1, b: 2 }
      .tap (res)->
        res.a.should.equal 1
        res.b.should.equal 2
        return
      .then (res)->
        res.a.should.equal 1
        res.b.should.equal 2
        done()
      .catch done

      return

    it 'should pass errors', (done)->
      Promise.reject new Error('hello')
      .tap undesiredRes(done)
      .catch (err)->
        err.message.should.equal 'hello'
        done()
      .catch done

      return

    it 'should not fail silently', (done)->
      Promise.resolve { a: 1, b: 2 }
      .tap (res)-> throw new Error('oh no')
      .then undesiredRes(done)
      .catch (err)->
        err.message.should.equal 'oh no'
        done()
      .catch done

      return

  describe 'resolved', ->
    it 'should be a resolved promise', (done)->
      Promise.resolved.should.be.an.Object()
      Promise.resolved.then.should.be.a.Function()
      Promise.resolved.catch.should.be.a.Function()
      Promise.resolved.then -> done()
      return

    it 'should not be modifiable', (done)->
      Promise.resolved.wat = 'yo'
      should(Promise.resolved.wat).not.be.ok()
      done()

  describe 'filter', ->
    it 'should be a function', (done)->
      Promise::filter.should.be.a.Function()
      done()

    it 'should filter results', (done)->
      Promise.all [
        1
        2
        Promise.resolve 3
      ]
      .filter (num)-> num > 1
      .then (res)->
        res.should.deepEqual [ 2, 3 ]
        done()
      .catch done

      return

    it 'should filter results from an array containing promises', (done)->
      Promise.resolve [
        1
        2
        Promise.resolve 3
      ]
      .filter (num)-> num > 1
      .then (res)->
        res.should.deepEqual [ 2, 3 ]
        done()
      .catch done

      return

    it 'should pass errors', (done)->
      Promise.all [
        Promise.resolve 123
        Promise.reject new Error('hello')
      ]
      .filter undesiredRes(done)
      .catch (err)->
        err.message.should.equal 'hello'
        done()
      .catch done

      return

  describe 'map', ->
    it 'should be a function', (done)->
      Promise::map.should.be.a.Function()
      done()

    it 'should map results', (done)->
      Promise.all [
        1
        2
        Promise.resolve 3
      ]
      .map (num)-> num * 2
      .then (res)->
        res.should.deepEqual [ 2, 4, 6 ]
        done()
      .catch done

      return

    it 'should map results from an array containing promises', (done)->
      Promise.resolve [
        1
        2
        Promise.resolve 3
      ]
      .map (num)-> num * 2
      .then (res)->
        res.should.deepEqual [ 2, 4, 6 ]
        done()
      .catch done

      return

    it 'should map return resolved values', (done)->
      Promise.resolve [ 1, 2, 3 ]
      .map (num)-> Promise.resolve num * 2
      .then (res)->
        res.should.deepEqual [ 2, 4, 6 ]
        done()
      .catch done

      return

    it 'should pass errors', (done)->
      Promise.resolve [
        Promise.resolve 123
        Promise.reject new Error('hello')
      ]
      .map undesiredRes(done)
      .catch (err)->
        err.message.should.equal 'hello'
        done()
      .catch done

      return

  describe 'reduce', ->
    it 'should be a function', (done)->
      Promise::reduce.should.be.a.Function()
      done()

    it 'should reduce results', (done)->
      sum = (a, b)-> a + b
      Promise.resolve [
        1
        2
        Promise.resolve 3
      ]
      .reduce sum, 5
      .then (res)->
        res.should.equal 11
        done()
      .catch done

      return

    it 'should reduce results from an array containing promises', (done)->
      sum = (a, b)-> a + b
      Promise.all [
        1
        2
        Promise.resolve 3
      ]
      .reduce sum, 5
      .then (res)->
        res.should.equal 11
        done()
      .catch done

      return

    it 'should pass errors', (done)->
      Promise.all [
        Promise.resolve 123
        Promise.reject new Error('hello')
      ]
      .reduce undesiredRes(done)
      .catch (err)->
        err.message.should.equal 'hello'
        done()
      .catch done

      return
