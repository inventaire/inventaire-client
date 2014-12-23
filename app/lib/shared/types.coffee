module.exports =
  type: (obj, type)->
    trueType = @typeOf obj
    if type is trueType then return obj
    else throw new Error "TypeError: expected #{type}, got #{obj} (#{trueType})"

  types: (args, types, minArgsLength)->
    args = @toArray(args)
    if minArgsLength? then test = types.length >= args.length >= minArgsLength
    else test = args.length is types.length
    unless test
      if minArgsLength? then err = "expected between #{minArgsLength} and #{types.length} arguments, got #{args.length}"
      else err = "expected #{types.length} arguments, got #{args.length}"
      throw new Error err
    i = 0
    while i < args.length
      @type args[i], types[i]
      i += 1

  typeOf: (obj)->
    # just handling what differes from typeof
    type = typeof obj
    if type is 'object'
      if @isNull(obj) then return 'null'
      if @isArray(obj) then return 'array'
    return type

  # soft testing: doesn't throw
  areStrings: (array)-> @all array, @isString

  typeString: (str)-> @type str, 'string'
  typeArray: (array)-> @type array, 'array'
