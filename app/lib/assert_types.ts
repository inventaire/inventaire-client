import { newError } from '#app/lib/error'
import typeOf from '#app/lib/type_of'

export function assertType (obj, type) {
  const trueType = typeOf(obj)
  if (type.split('|').includes(trueType)) {
    return obj
  } else {
    const err = newError(`TypeError: expected ${type}, got ${JSON.stringify(obj)} (${trueType})`)
    err.context = arguments
    throw err
  }
}

export function assertTypes (args, types) {
  // In case it's an 'arguments' object
  args = Array.from(args)

  // accepts a common type for all the args as a string
  // ex: types = 'numbers...'
  // or even 'numbers...|strings...' to be translated as several 'number|string'
  // => types = ['number', 'number', ... (args.length times)]
  if ((typeof types === 'string') && (types.split('s...').length > 1)) {
    const uniqueType = types.split('s...').join('')
    types = duplicatesArray(uniqueType, args.length)
  }

  // testing arguments types once polymorphic interfaces are normalized
  assertType(args, 'array')
  assertType(types, 'array')

  const test = args.length === types.length

  if (!test) {
    throw newError(`expected ${types.length} arguments, got ${args.length}: ${args}`, { arguments })
  }

  let i = 0
  try {
    while (i < args.length) {
      assertType(args[i], types[i])
      i += 1
    }
  } catch (err) {
    err.context = { arguments }
    throw err
  }
}

const duplicatesArray = (str, length) => new Array(length).fill(str)

// Same functions with proper type assertion
export function assertString (str: unknown): asserts str is string {
  assertType(str, 'string')
}

export function assertNumber (num: unknown): asserts num is number {
  assertType(num, 'number')
}

export function assertBoolean (bool: unknown): asserts bool is boolean {
  assertType(bool, 'boolean')
}

export function assertArray (arr: unknown): asserts arr is unknown[] {
  assertType(arr, 'array')
}

export function assertObject (obj: unknown): asserts obj is object {
  assertType(obj, 'object')
}

// eslint-disable-next-line @typescript-eslint/no-unsafe-function-type
export function assertFunction (fn: unknown): asserts fn is Function {
  assertType(fn, 'function')
}

export function assertPromise (promise: unknown): asserts promise is Promise<unknown> {
  assertType(promise, 'promise')
}

export function assertStrings (strings: unknown[]): asserts strings is string[] {
  assertTypes(strings, 'strings...')
}

export function assertNumbers (numbers: unknown[]): asserts numbers is number[] {
  assertTypes(numbers, 'numbers...')
}

export function assertArrays (arrays: unknown[]): asserts arrays is unknown[][] {
  assertTypes(arrays, 'arrays...')
}

export function assertObjects (objects: unknown[]): asserts objects is object[] {
  assertTypes(objects, 'objects...')
}
