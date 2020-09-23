import should from 'should'
import _ from './utils_builder'

describe('Types utils', () => {
  describe('TYPEOF', () => it('should return the right type', done => {
    _.typeOf('hello').should.equal('string')
    _.typeOf([ 'hello' ]).should.equal('array')
    _.typeOf({ hel: 'lo' }).should.equal('object')
    _.typeOf(83110).should.equal('number')
    _.typeOf(null).should.equal('null')
    _.typeOf().should.equal('undefined')
    _.typeOf(false).should.equal('boolean')
    _.typeOf(Number('boudu')).should.equal('NaN')
    return done()
  }))

  describe('TYPE', () => {
    describe('STRING', () => {
      it('should throw on false string', done => {
        ((() => _.type([ 'im an array' ], 'string'))).should.throw();
        ((() => _.type(1252154125123, 'string'))).should.throw();
        ((() => _.type({ whoami: 'im an object' }, 'string'))).should.throw()
        return done()
      })

      return it('should not throw on true string', done => {
        ((() => _.type('im am a string', 'string'))).should.not.throw()
        return done()
      })
    })

    describe('NUMBER', () => {
      it('should throw on false number', done => {
        ((() => _.type([ 'im an array' ], 'number'))).should.throw();
        ((() => _.type('im am a string', 'number'))).should.throw();
        ((() => _.type({ whoami: 'im an object' }, 'number'))).should.throw()
        return done()
      })

      return it('should not throw on true number', done => {
        ((() => _.type(1252154125123, 'number'))).should.not.throw()
        return done()
      })
    })

    describe('ARRAY', () => {
      it('should throw on false array', done => {
        ((() => _.type('im am a string', 'array'))).should.throw();
        ((() => _.type(1252154125123, 'array'))).should.throw();
        ((() => _.type({ whoami: 'im an object' }, 'array'))).should.throw()
        return done()
      })

      return it('should not throw on true array', done => {
        ((() => _.type([ 'im an array' ], 'array'))).should.not.throw()
        return done()
      })
    })

    describe('OBJECT', () => {
      it('should throw on false object', done => {
        ((() => _.type('im am a string', 'object'))).should.throw();
        ((() => _.type(1252154125123, 'object'))).should.throw();
        ((() => _.type([ 'im an array' ], 'object'))).should.throw()
        return done()
      })

      return it('should not throw on true object', done => {
        ((() => _.type({ whoami: 'im an object' }, 'object'))).should.not.throw()
        return done()
      })
    })

    return describe('GENERAL', () => {
      it('should return the passed object', done => {
        const array = [ 'im an array' ]
        _.type(array, 'array').should.equal(array)
        const obj = { im: 'an array' }
        _.type(obj, 'object').should.equal(obj)
        return done()
      })

      it('should accept mutlitple possible types separated by | ', done => {
        ((() => _.type(1252154, 'number|null'))).should.not.throw();
        ((() => _.type(null, 'number|null'))).should.not.throw();
        ((() => _.type('what?', 'number|null'))).should.throw()
        return done()
      })

      return it('should throw when none of the multi-types is true', done => {
        ((() => _.type('what?', 'number|null'))).should.throw();
        ((() => _.type({ andthen: 'what?' }, 'array|string'))).should.throw()
        return done()
      })
    })
  })

  describe('TYPES', () => {
    it('should handle multi arguments type', done => {
      const obj = { whoami: 'im an object' };
      ((() => _.types([ obj ], [ 'object' ]))).should.not.throw();
      ((() => _.types([ obj, 2, 125 ], [ 'object', 'number', 'number' ]))).should.not.throw()
      return done()
    })

    it('should handle throw when an argument is of the wrong type', done => {
      const obj = { whoami: 'im an object' }
      const args = [ obj, 1, 2, 125 ];
      ((() => _.types(args, [ 'object', 'number', 'string', 'number' ]))).should.throw();
      ((() => _.types([ obj, 1, 'hello', 125 ], [ 'object', 'array', 'string', 'number' ]))).should.throw()
      return done()
    })

    it('should throw when not enought arguments', done => {
      ((() => _.types([ { whoami: 'im an object' }, 1 ], [ 'object', 'number', 'array' ]))).should.throw()
      return done()
    })

    it('should throw when too many arguments', done => {
      ((() => _.types([ { whoami: 'im an object' }, [ 1, [ 123 ], 2, 3 ], 'object', 'number', 'array' ]))).should.throw()
      return done()
    })

    it('should not throw when less arguments than types but more or as many as minArgsLength', done => {
      ((() => _.types([ 'i am a string' ], [ 'string', 'string' ]))).should.throw();
      ((() => _.types([ 'i am a string' ], [ 'string', 'string' ], 0))).should.not.throw();
      ((() => _.types([ 'i am a string' ], [ 'string', 'string' ], 1))).should.not.throw();
      ((() => _.types([ 'i am a string' ], [ 'string', 'boolean|undefined' ], 1))).should.not.throw();
      ((() => _.types([ 'i am a string' ], [ 'string', 'boolean|undefined' ], 1))).should.not.throw();
      ((() => _.types([ 'i am a string' ], [ 'string' ], 0))).should.not.throw();
      ((() => _.types([ 'i am a string' ], [ 'string' ], 1))).should.not.throw()
      return done()
    })

    it('should throw when less arguments than types and not more or as many as minArgsLength', done => {
      ((() => _.types([ 'im am a string' ], [ 'string', 'string' ], 2))).should.throw()
      return done()
    })

    it('accepts a common type for all the args as a string', done => {
      ((() => _.types([ 1, 2, 3, 41235115 ], 'numbers...'))).should.not.throw();
      ((() => _.types([ 1, 2, 3, 41235115, 'bobby' ], 'numbers...'))).should.throw()
      return done()
    })

    it("only accepts the 's...' interface", done => {
      ((() => _.types([ 1, 2, 3, 41235115 ], 'numbers'))).should.throw()
      return done()
    })

    it("should accept piped 's...' types", done => {
      ((() => _.types([ 1, 2, 'yo', 41235115 ], 'strings...|numbers...'))).should.not.throw();
      ((() => _.types([ 1, 2, 'yo', [], 41235115 ], 'strings...|numbers...'))).should.throw()
      return done()
    })

    it('common types should accept receiving 0 argument', done => {
      ((() => _.types([], 'numbers...'))).should.not.throw()
      return done()
    })

    return it('common types should accept receiving 1 argument', done => {
      ((() => _.types([ 123 ], 'numbers...'))).should.not.throw()
      return done()
    })
  })

  describe('ALL', () => describe('areStrings', () => {
    it('should be true when all are strings', done => {
      _.areStrings([ 'a', 'b', 'c' ]).should.equal(true)
      return done()
    })

    return it('should be false when not all are strings', done => {
      _.areStrings([ 'a', 'b', 4 ]).should.equal(false)
      _.areStrings([ 'a', { a: 12 }, 4 ]).should.equal(false)
      _.areStrings([ [], 'e', 'f' ]).should.equal(false)
      return done()
    })
  }))

  return describe('forceArray', done => {
    it('should return an array for an array', done => {
      const a = _.forceArray([ 1, 2, 3, { zo: 'hello' }, null ])
      a.should.be.an.Array()
      a.length.should.equal(5)
      return done()
    })

    it('should return an array for a string', done => {
      const a = _.forceArray('yolo')
      a.should.be.an.Array()
      a.length.should.equal(1)
      return done()
    })

    it('should return an array for a number', done => {
      const a = _.forceArray(125)
      a.should.be.an.Array()
      a.length.should.equal(1)
      const b = _.forceArray(-12612125)
      b.should.be.an.Array()
      b.length.should.equal(1)
      return done()
    })

    it('should return an array for an object', done => {
      const a = _.forceArray({ bon: 'jour' })
      a.should.be.an.Array()
      a.length.should.equal(1)
      return done()
    })

    it('should return an empty array for null', done => {
      const a = _.forceArray(null)
      a.should.be.an.Array()
      a.length.should.equal(0)
      return done()
    })

    it('should return an empty array for undefined', done => {
      const a = _.forceArray(null)
      a.should.be.an.Array()
      a.length.should.equal(0)
      return done()
    })

    it('should return an empty array for an empty input', done => {
      const a = _.forceArray()
      a.should.be.an.Array()
      a.length.should.equal(0)
      return done()
    })

    return it('should return an empty array for an empty string', done => {
      const a = _.forceArray('')
      a.should.be.an.Array()
      a.length.should.equal(0)
      return done()
    })
  })
})
