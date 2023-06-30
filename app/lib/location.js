import { readable } from 'svelte/store'
import { debounce } from 'underscore'

export const parseQuery = function (queryString) {
  if (queryString == null) return {}
  return queryString
  .replace(/^\?/, '')
  .split('&')
  .reduce(parseKeysValues, {})
}

export const setQuerystring = function (url, key, value) {
  const [ href, qs ] = url.split('?')
  const qsObj = parseQuery(qs)
  // override the previous key/value
  if (value != null) {
    qsObj[key] = value
  } else {
    delete qsObj[key]
  }
  return buildPath(href, qsObj)
}

// Calling a section the first part of the route matching to a module
// ex: for '/inventory/bla/bla', the section is 'inventory'
// Split on the first non-alphabetical character
export const routeSection = route => route.split(/[^\w]/)[0]

export const buildPath = function (pathname, queryObj, escape) {
  queryObj = removeUndefined(queryObj)
  if ((queryObj == null) || _.isEmpty(queryObj)) return pathname

  let queryString = ''

  for (const key in queryObj) {
    let value = queryObj[key]
    if (escape) {
      value = dropSpecialCharacters(value)
    }
    if (_.isObject(value)) {
      value = escapeQueryStringValue(JSON.stringify(value))
    }
    queryString += `&${key}=${value}`
  }

  return pathname + '?' + queryString.slice(1)
}

export const currentRoute = () => location.pathname.slice(1)

export const currentRouteWithQueryString = () => location.pathname.slice(1) + location.search

export const currentSection = () => routeSection(currentRoute())

const parseKeysValues = function (queryObj, nextParam) {
  const pairs = nextParam.split('=')
  let [ key, value ] = pairs
  if ((key?.length > 0) && (value != null)) {
    // Try to parse the value, allowing JSON strings values
    // like data={%22wdt:P50%22:[%22wd:Q535%22]}
    value = permissiveJsonParse(decodeURIComponent(value))
    // If a number string was parsed into a number, make it a string again
    // so that the output stays predictible
    if (_.isNumber(value)) value = value.toString()
    queryObj[key] = value
  }

  return queryObj
}

const permissiveJsonParse = input => {
  if (input[0] === '{' || input[0] === '[') {
    try {
      return JSON.parse(input)
    } catch (err) {
      return input
    }
  } else {
    return input
  }
}

// Only escape values that are problematic in a query string:
// for the moment, only '?'
const escapeQueryStringValue = str => str.replace(/\?/g, '%3F')

const dropSpecialCharacters = str => {
  return str
  .replace(/\s+/g, ' ')
  .replace(/(\?|:)/g, '')
}

const removeUndefined = function (obj) {
  const newObj = {}
  for (const key in obj) {
    const value = obj[key]
    if (value != null) newObj[key] = value
  }
  return newObj
}

function getLocationData (section, route) {
  route = route || currentRoute()
  return {
    route,
    section: routeSection(route),
  }
}

export const locationStore = readable(getLocationData(), set => {
  const update = (section, route) => set(getLocationData(section, route))
  const lazyUpdate = debounce(update, 100)
  app.vent.on('route:change', lazyUpdate)
  return () => app.vent.off('route:change', lazyUpdate)
})
