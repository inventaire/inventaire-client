module.exports = (_)->
  idGenerator: (length, lettersOnly)->
    text = ''
    possible = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
    possible += '0123456789'  unless lettersOnly
    i = 0
    while i < length
      text += possible.charAt _.random(possible.length - 1)
      i++
    return text

  # adapted from http://werxltd.com/wp/2010/05/13/javascript-implementation-of-javas-string-hashcode-method/
  hashCode: (string)->
    [hash, i, len] = [0, 0, string.length]
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
        queryString += "&#{k}=#{v}"
      return pathname + '?' + queryString[1..-1]
    else pathname

  isUrl: (str)->
    # adapted from http://stackoverflow.com/a/14582229/3324977
    pattern = '^(https?:\\/\\/)'+ # protocol
      '(\\w+:\\w+@)?'+ # auth?
      '((([a-z\\d]([a-z\\d-_]*[a-z\\d])*)\\.)+[a-z]{2,}|'+ # domain name
      '((\\d{1,3}\\.){3}\\d{1,3}))|'+ # OR ip (v4) address
      '(localhost)'+ # OR localhost
      '(\\:\\d+)?' + # port?
      '(\\/[-a-z\\d%_.~+]*)*'+ # path
      '(\\?[;&a-z\\d%_.~+=-]*)?'+ # query string?
      '(\\#[-a-z\\d_]*)?$' #fragment?

    regexp = new RegExp pattern , "i"
    return regexp.test str

  matchesCount: (arrays...)-> _.intersection.apply(_, arrays).length
  haveAMatch: (arrays...)-> _.matchesCount.apply(null, arrays) > 0

  objLength: (obj)-> Object.keys(obj)?.length

  expired: (timestamp, ttl)-> Date.now() - timestamp > ttl

  isNonEmptyString: (str)-> _.isString(str) and str.length > 0

  shortLang: (lang)-> lang?[0..1]

  # Returns a function ready to be called without accepting further arguments
  # usefull in promises chains, when the previous event might return
  # an unnecessary argument
  # It does nothing more than what would do an anonymous function
  # but it is explicit about what it does, while OCD-prone developers
  # might look at an anonymous function wanting to turn it into a named function
  Full: (fn, context, args...)-> fullFn = -> fn.apply context, args

removeUndefined = (obj)->
  newObj = {}
  for k,v of obj
    if v? then newObj[k] = v
  return newObj

dropSpecialCharacters = (str)->
  str
  .replace /\s+/g, ' '
  .replace /(\?|\:)/g, ''
