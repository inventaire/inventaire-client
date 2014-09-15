Array::clone = -> @slice(0)


module.exports =
  hasValue: (array, value)-> array.indexOf(value) isnt -1

  idGenerator: (length, withoutNumbers)->
    text = ''
    if withoutNumbers
      possible = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
    else
      possible = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
    i = 0
    while i < length
      text += possible.charAt(Math.floor(Math.random() * possible.length))
      i++
    return text

  # weak but handy
  hasDiff: (obj1, obj2)-> JSON.stringify(obj1) != JSON.stringify(obj2)

  wmCommonsThumb: (file, width=100)->
    "http://commons.wikimedia.org/w/thumb.php?width=#{width}&f=#{file}"

  buildPath: (pathname, queryObj, escape)->
    if queryObj? and not _.isEmpty queryObj
      queries = ''
      for k,v of queryObj
        v = @dropSpecialCharacters(v)  if escape
        queries += "&#{k}=#{v}"
      return pathname + '?' + queries[1..-1]
    else pathname

  dropSpecialCharacters : (str)->
    str.replace(/\s+/g, ' ').replace(/(\?|\:)/g, '')

  typeString: (str)->
    if typeof str is 'string' then str
    else throw new Error "TypeError: #{str} instead of String"

  toSet: (array)->
    obj = {}
    array.forEach (value)-> obj[value] = true
    return Object.keys(obj)
