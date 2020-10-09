import { typeOf } from 'lib/utils'

const assertType = function (obj, type) {
  const trueType = typeOf(obj)
  if (type.split('|').includes(trueType)) {
    return obj
  } else {
    const err = new Error(`TypeError: expected ${type}, got ${JSON.stringify(obj)} (${trueType})`)
    err.context = arguments
    throw err
  }
}

const assertTypes = function (args, types, minArgsLength) {
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
  if (minArgsLength != null) assertType(minArgsLength, 'number')

  let test
  if (minArgsLength != null) {
    test = types.length >= args.length && args.length >= minArgsLength
  } else {
    test = args.length === types.length
  }

  if (!test) {
    let err
    if (minArgsLength != null) {
      err = `expected between ${minArgsLength} and ${types.length} arguments ,` +
        `got ${args.length}: ${args}`
    } else {
      err = `expected ${types.length} arguments, got ${args.length}: ${args}`
    }
    err = new Error(err)
    err.context = arguments
    throw err
  }

  let i = 0
  try {
    while (i < args.length) {
      assertType(args[i], types[i])
      i += 1
    }
  } catch (err) {
    err.context = arguments
    throw err
  }
}

const duplicatesArray = (str, length) => new Array(length).fill(str)

export default {
  type: assertType,
  types: assertTypes,
  string: str => assertType(str, 'string'),
  number: num => assertType(num, 'number'),
  array: array => assertType(array, 'array'),
  object: obj => assertType(obj, 'object'),
  strings: args => assertTypes(args, 'strings...'),
  objects: args => assertTypes(args, 'objects...'),
}
