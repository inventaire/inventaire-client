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
      queryString.split('&').forEach (param)->
        pairs = param.split '='
        if pairs[0]?.length > 0 and pairs[1]?
          query[pairs[0]] = _.softDecodeURI pairs[1]
    return query

  softEncodeURI: (str)->
    if _.typeString(str)
      str.replace(/(\s|')/g, '_').replace(/\?/g, '')

  softDecodeURI: (str)->
    if _.typeString(str)
      str.replace(/_/g,' ')

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
    else
      obj = JSON.stringify str
      throw new Error "TypeError: expected a String, got: #{obj}"

  typeArray: (array)->
    if array instanceof Array then array
    else throw new Error "TypeError: #{array} instead of Array"

  isUrl: (str)->
    # not perfect, just roughly filtering
    # accepts url delegating protocol choice to the browser with only '//'
    pattern = new RegExp('^((https?:|)\\/\\/)?(([a-z\\d]([a-z\\d-]*[a-z\\d])*)\\.)+[a-z]{2,}')
    return pattern.test(str)

  isDataUrl: (str)-> /^data:image/.test str

  isHostedPicture: (str)-> /(imgloc|img).inventaire.io\/\w{22}.jpg$/.test str

  pickToArray: (obj, propsArray)->
    if _.typeArray propsArray
      pickObj = _.pick(obj, propsArray)
      # returns an undefined array element when prop is undefined
      return propsArray.map (prop)-> pickObj[prop]

  mergeArrays: _.union

  haveAMatch: (arrays...)-> _.intersection.apply(_, arrays).length > 0
