export default {
  type (obj, type) {
    const trueType = _.typeOf(obj)
    if (type.split('|').includes(trueType)) {
      return obj
    } else {
      const err = new Error(`TypeError: expected ${type}, got ${JSON.stringify(obj)} (${trueType})`)
      err.context = arguments
      throw err
    }
  },

  types (args, types, minArgsLength) {
    // in case it's an 'arguments' object
    let err, test
    args = _.toArray(args)

    // accepts a common type for all the args as a string
    // ex: types = 'numbers...'
    // or even 'numbers...|strings...' to be translated as several 'number|string'
    // => types = ['number', 'number', ... (args.length times)]
    if ((typeof types === 'string') && (types.split('s...').length > 1)) {
      const uniqueType = types.split('s...').join('')
      types = duplicatesArray(uniqueType, args.length)
    }

    // testing arguments types once polymorphic interfaces are normalized
    _.type(args, 'array')
    _.type(types, 'array')
    if (minArgsLength != null) { _.type(minArgsLength, 'number') }

    if (minArgsLength != null) {
      test = types.length >= args.length && args.length >= minArgsLength
    } else { test = args.length === types.length }

    if (!test) {
      if (minArgsLength != null) {
        err = `expected between ${minArgsLength} and ${types.length} arguments ,` +
          `got ${args.length}: ${args}`
      } else {
        err = `expected ${types.length} arguments, got ${args.length}: ${args}`
      }
      console.log(args)
      err = new Error(err)
      err.context = arguments
      throw err
    }

    let i = 0
    try {
      while (i < args.length) {
        _.type(args[i], types[i])
        i += 1
      }
    } catch (error) {
      err = error
      err.context = arguments
      throw err
    }
  },

  typeOf (obj) {
    // just handling what differes from typeof
    const type = typeof obj
    if (type === 'object') {
      if (_.isNull(obj)) { return 'null' }
      if (_.isArray(obj)) { return 'array' }
    }
    if (type === 'number') {
      if (_.isNaN(obj)) { return 'NaN' }
    }
    return type
  },

  // soft testing: doesn't throw
  areStrings (array) { return _.all(array, _.isString) },

  typeString (str) { return _.type(str, 'string') },
  typeArray (array) { return _.type(array, 'array') },

  // helpers to simplify polymorphisms
  forceArray (keys) {
    if ((keys == null) || (keys === '')) { return [] }
    if (!_.isArray(keys)) {
      return [ keys ]
    } else { return keys }
  },

  forceObject (key, value) {
    if (!_.isObject(key)) {
      const obj = {}
      obj[key] = value
      return obj
    } else { return key }
  }
}

const duplicatesArray = (str, length) => new Array(length).fill(str)
