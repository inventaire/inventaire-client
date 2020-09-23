parseQuery = (queryString)->
  unless queryString? then return {}
  queryString
  .replace /^\?/, ''
  .split '&'
  .reduce parseKeysValues, {}

setQuerystring = (url, key, value)->
  [ href, qs ] = url.split '?'
  qsObj = parseQuery qs
  # override the previous key/value
  qsObj[key] = value
  return buildPath href, qsObj

# calling a section the first part of the route matching to a module
# ex: for '/inventory/bla/bla', the section is 'inventory'
routeSection = (route)->
  # split on the first non-alphabetical character
  route.split(/[^\w]/)[0]

buildPath = (pathname, queryObj, escape)->
  queryObj = removeUndefined queryObj
  if not queryObj? or _.isEmpty(queryObj) then return pathname

  queryString = ''

  for key, value of queryObj
    if escape
      value = dropSpecialCharacters value
    if _.isObject value
      value = escapeQueryStringValue JSON.stringify(value)
    queryString += "&#{key}=#{value}"

  return pathname + '?' + queryString[1..-1]

currentRoute = -> location.pathname.slice(1)

currentSection = -> routeSection currentRoute()

parseKeysValues = (queryObj, nextParam)->
  pairs = nextParam.split '='
  [ key, value ] = pairs
  if key?.length > 0 and value?
    # Try to parse the value, allowing JSON strings values
    # like data={%22wdt:P50%22:[%22wd:Q535%22]}
    value = permissiveJsonParse decodeURIComponent(value)
    # If a number string was parsed into a number, make it a string again
    # so that the output stays predictible
    if _.isNumber value then value = value.toString()
    queryObj[key] = value

  return queryObj

permissiveJsonParse = (input)->
  try JSON.parse input
  catch err then input

# Only escape values that are problematic in a query string:
# for the moment, only '?'
escapeQueryStringValue = (str)-> str.replace /\?/g, '%3F'

dropSpecialCharacters = (str)->
  str
  .replace /\s+/g, ' '
  .replace /(\?|\:)/g, ''

removeUndefined = (obj)->
  newObj = {}
  for key, value of obj
    if value? then newObj[key] = value
  return newObj

module.exports = { parseQuery, setQuerystring, routeSection, buildPath, currentRoute, currentSection }
