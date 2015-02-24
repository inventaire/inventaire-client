module.exports =
  type: (obj, type)->
    trueType = @typeOf obj
    if trueType in type.split('|') then return obj
    else throw new Error "TypeError: expected #{type}, got #{obj} (#{trueType})"

  types: (args, types, minArgsLength)->

    # in case it's an 'arguments' object
    args = @toArray(args)

    # accepts a common type for all the args as a string
    # ex: types = 'numbers...'
    # => types = ['number', 'number', ... (args.length times)]
    if typeof types is 'string' and types.split('s...').length is 2
      uniqueType = types.split('s...')[0]
      types = @duplicatesArray uniqueType, args.length

    # testing arguments types once polymorphic interfaces are normalized
    @type args, 'array'
    @type types, 'array'
    @type minArgsLength, 'number'  if minArgsLength?

    if minArgsLength?
      test = types.length >= args.length >= minArgsLength
    else test = args.length is types.length

    unless test
      if minArgsLength? then err = "expected between #{minArgsLength} and #{types.length} arguments, got #{args.length}: #{args}"
      else err = "expected #{types.length} arguments, got #{args.length}: #{args}"
      console.log args
      throw new Error err
    i = 0
    try
      while i < args.length
        @type args[i], types[i]
        i += 1
    catch err
      @error arguments, 'types err arguments'
      throw err

  typeOf: (obj)->
    # just handling what differes from typeof
    type = typeof obj
    if type is 'object'
      if @isNull(obj) then return 'null'
      if @isArray(obj) then return 'array'
    if type is 'number'
      if @isNaN(obj) then return 'NaN'
    return type

  # soft testing: doesn't throw
  areStrings: (array)-> @all array, @isString

  typeString: (str)-> @type str, 'string'
  typeArray: (array)-> @type array, 'array'
  forceArray: (keys)->
    unless @isArray(keys) then [keys]
    else keys