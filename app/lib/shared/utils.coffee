module.exports = (_)->
  # adapted from http://werxltd.com/wp/2010/05/13/javascript-implementation-of-javas-string-hashcode-method/
  hashCode: (string)->
    [ hash, i, len ] = [ 0, 0, string.length ]
    if len is 0 then return hash

    while i < len
      chr = string.charCodeAt(i)
      hash = ((hash << 5) - hash) + chr
      hash |= 0 # Convert to 32bit integer
      i++
    Math.abs hash

  buildPath: (pathname, queryObj, escape)->
    queryObj = removeUndefined queryObj
    if queryObj? and not _.isEmpty queryObj
      queryString = ''
      for k,v of queryObj
        if escape then v = dropSpecialCharacters v
        if _.isObject v then v = JSON.stringify v
        queryString += "&#{k}=#{v}"
      return pathname + '?' + queryString[1..-1]
    else pathname

  matchesCount: (arrays...)-> _.intersection.apply(_, arrays).length
  haveAMatch: (arrays...)-> _.matchesCount.apply(null, arrays) > 0

  objLength: (obj)-> Object.keys(obj)?.length

  expired: (timestamp, ttl)-> Date.now() - timestamp > ttl

  isNonEmptyString: (str)-> _.isString(str) and str.length > 0
  isNonEmptyArray: (array)-> _.isArray(array) and array.length > 0
  isNonEmptyPlainObject: (obj)->
    _.isPlainObject(obj) and Object.keys(obj).length > 0

  shortLang: (lang)-> lang?[0..1]

  # Returns a function ready to be called without accepting further arguments
  # usefull in promises chains, when the previous event might return
  # an unnecessary argument
  # It does nothing more than what would do an anonymous function
  # but it is explicit about what it does, while OCD-prone developers
  # might look at an anonymous function wanting to turn it into a named function
  Full: (fn, context, args...)-> fullFn = -> fn.apply context, args

  # encodeURIComponent ignores !, ', (, ), and *
  # cf https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/encodeURIComponent#Description
  fixedEncodeURIComponent: (str)->
    encodeURIComponent(str).replace /[!'()*]/g, encodeCharacter

  pickOne: (obj)->
    key = Object.keys(obj)[0]
    if key? then return obj[key]

  isDataUrl: (str)-> /^data:image/.test str

  bestImageWidth: (width)->
    # under 500, it's useful to keep the freedom to get exactly 64 or 128px etc
    # while still grouping on the initially requested width
    if width < 500 then return width

    # if in a browser, use the screen width as a max value
    if screen?.width then width = Math.min width, screen.width
    # group image width above 500 by levels of 100px to limit generated versions
    return Math.ceil(width / 100) * 100

  parseBooleanString: (booleanString)-> booleanString is 'true'

  simpleDay: (date)->
    if date? then new Date(date).toISOString().split('T')[0]
    else new Date().toISOString().split('T')[0]

  isPositiveIntegerString: (str)-> _.isString(str) and /^\d+$/.test str

encodeCharacter = (c)-> '%' + c.charCodeAt(0).toString(16)

removeUndefined = (obj)->
  newObj = {}
  for k,v of obj
    if v? then newObj[k] = v
  return newObj

dropSpecialCharacters = (str)->
  str
  .replace /\s+/g, ' '
  .replace /(\?|\:)/g, ''
