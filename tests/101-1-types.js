import 'should'
import assert_ from '#lib/assert_types'
const { type: assertType, types: assertTypes } = assert_

describe('assert types', () => {
  describe('type', () => {
    describe('string', () => {
      it('should throw on false string', () => {
        ((() => assertType([ 'im an array' ], 'string'))).should.throw();
        ((() => assertType(1252154125123, 'string'))).should.throw();
        ((() => assertType({ whoami: 'im an object' }, 'string'))).should.throw()
      })

      it('should not throw on true string', () => {
        ((() => assertType('im am a string', 'string'))).should.not.throw()
      })
    })

    describe('number', () => {
      it('should throw on false number', () => {
        ((() => assertType([ 'im an array' ], 'number'))).should.throw();
        ((() => assertType('im am a string', 'number'))).should.throw();
        ((() => assertType({ whoami: 'im an object' }, 'number'))).should.throw()
      })

      it('should not throw on true number', () => {
        ((() => assertType(1252154125123, 'number'))).should.not.throw()
      })
    })

    describe('array', () => {
      it('should throw on false array', () => {
        ((() => assertType('im am a string', 'array'))).should.throw();
        ((() => assertType(1252154125123, 'array'))).should.throw();
        ((() => assertType({ whoami: 'im an object' }, 'array'))).should.throw()
      })

      it('should not throw on true array', () => {
        ((() => assertType([ 'im an array' ], 'array'))).should.not.throw()
      })
    })

    describe('object', () => {
      it('should throw on false object', () => {
        ((() => assertType('im am a string', 'object'))).should.throw();
        ((() => assertType(1252154125123, 'object'))).should.throw();
        ((() => assertType([ 'im an array' ], 'object'))).should.throw()
      })

      it('should not throw on true object', () => {
        ((() => assertType({ whoami: 'im an object' }, 'object'))).should.not.throw()
      })
    })

    describe('general', () => {
      it('should return the passed object', () => {
        const array = [ 'im an array' ]
        assertType(array, 'array').should.equal(array)
        const obj = { im: 'an array' }
        assertType(obj, 'object').should.equal(obj)
      })

      it('should accept mutlitple possible types separated by | ', () => {
        ((() => assertType(1252154, 'number|null'))).should.not.throw();
        ((() => assertType(null, 'number|null'))).should.not.throw();
        ((() => assertType('what?', 'number|null'))).should.throw()
      })

      it('should throw when none of the multi-types is true', () => {
        ((() => assertType('what?', 'number|null'))).should.throw();
        ((() => assertType({ andthen: 'what?' }, 'array|string'))).should.throw()
      })
    })
  })

  describe('types', () => {
    it('should handle multi arguments type', () => {
      const obj = { whoami: 'im an object' };
      ((() => assertTypes([ obj ], [ 'object' ]))).should.not.throw();
      ((() => assertTypes([ obj, 2, 125 ], [ 'object', 'number', 'number' ]))).should.not.throw()
    })

    it('should handle throw when an argument is of the wrong type', () => {
      const obj = { whoami: 'im an object' }
      const args = [ obj, 1, 2, 125 ];
      ((() => assertTypes(args, [ 'object', 'number', 'string', 'number' ]))).should.throw();
      ((() => assertTypes([ obj, 1, 'hello', 125 ], [ 'object', 'array', 'string', 'number' ]))).should.throw()
    })

    it('should throw when not enought arguments', () => {
      ((() => assertTypes([ { whoami: 'im an object' }, 1 ], [ 'object', 'number', 'array' ]))).should.throw()
    })

    it('should throw when too many arguments', () => {
      ((() => assertTypes([ { whoami: 'im an object' }, [ 1, [ 123 ], 2, 3 ], 'object', 'number', 'array' ]))).should.throw()
    })

    it('should not throw when less arguments than types but more or as many as minArgsLength', () => {
      ((() => assertTypes([ 'i am a string' ], [ 'string', 'string' ]))).should.throw();
      ((() => assertTypes([ 'i am a string' ], [ 'string', 'string' ], 0))).should.not.throw();
      ((() => assertTypes([ 'i am a string' ], [ 'string', 'string' ], 1))).should.not.throw();
      ((() => assertTypes([ 'i am a string' ], [ 'string', 'boolean|undefined' ], 1))).should.not.throw();
      ((() => assertTypes([ 'i am a string' ], [ 'string', 'boolean|undefined' ], 1))).should.not.throw();
      ((() => assertTypes([ 'i am a string' ], [ 'string' ], 0))).should.not.throw();
      ((() => assertTypes([ 'i am a string' ], [ 'string' ], 1))).should.not.throw()
    })

    it('should throw when less arguments than types and not more or as many as minArgsLength', () => {
      ((() => assertTypes([ 'im am a string' ], [ 'string', 'string' ], 2))).should.throw()
    })

    it('accepts a common type for all the args as a string', () => {
      ((() => assertTypes([ 1, 2, 3, 41235115 ], 'numbers...'))).should.not.throw();
      ((() => assertTypes([ 1, 2, 3, 41235115, 'bobby' ], 'numbers...'))).should.throw()
    })

    it("only accepts the 's...' interface", () => {
      ((() => assertTypes([ 1, 2, 3, 41235115 ], 'numbers'))).should.throw()
    })

    it("should accept piped 's...' types", () => {
      ((() => assertTypes([ 1, 2, 'yo', 41235115 ], 'strings...|numbers...'))).should.not.throw();
      ((() => assertTypes([ 1, 2, 'yo', [], 41235115 ], 'strings...|numbers...'))).should.throw()
    })

    it('common types should accept receiving 0 argument', () => {
      ((() => assertTypes([], 'numbers...'))).should.not.throw()
    })

    it('common types should accept receiving 1 argument', () => {
      ((() => assertTypes([ 123 ], 'numbers...'))).should.not.throw()
    })
  })

  describe('strings', () => {
    it("should throw if one of the passed values isn't a string", () => {
      assert_.strings.bind(null, [ 'abc', 123 ]).should.throw()
    })

    it("should throw if one of the passed values isn't a string", () => {
      assert_.strings([ 'abc', 'def' ])
    })
  })
})
