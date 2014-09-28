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
    queryObj = @removeUndefined(queryObj)
    if queryObj? and not _.isEmpty queryObj
      queryString = ''
      for k,v of queryObj
        v = @dropSpecialCharacters(v)  if escape
        queryString += "&#{k}=#{v}"
      return pathname + '?' + queryString[1..-1]
    else pathname

  parseQuery: (queryString)->
    query = new Object
    if queryString?
      queryString = queryString[1..-1] if queryString[0] is '?'
      for i in queryString.split('&')
        pair = i.split '='
        if pair[0]?.length > 0 and pair[1]?
          query[pair[0]] = pair[1].replace(/_/g, ' ')
    return query

  removeUndefined: (obj)->
    newObj = {}
    for k,v of obj
      if v? then newObj[k] = v
      else console.warn "#{k}:#{v} omitted"
    return newObj

  dropSpecialCharacters : (str)->
    str.replace(/\s+/g, ' ').replace(/(\?|\:)/g, '')

  typeString: (str)->
    if typeof str is 'string' then str
    else throw new Error "TypeError: #{str} instead of String"

  toSet: (array)->
    obj = {}
    array.forEach (value)-> obj[value] = true
    return Object.keys(obj)

  isUrl: (str)->
    # not perfect, just roughly filtering
    pattern = new RegExp('^(https?:\\/\\/)?(([a-z\\d]([a-z\\d-]*[a-z\\d])*)\\.)+[a-z]{2,}')
    if not pattern.test(str)
      alert("Please enter a valid URL.")
      return false
    else true
