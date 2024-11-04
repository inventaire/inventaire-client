import { isObject, isNumber, isEmpty } from 'underscore'
import type { Url } from '#server/types/common'
import { objectEntries } from './utils'

export function parseQuery (queryString?: string) {
  if (queryString == null) return {}
  return queryString
  .replace(/^\?/, '')
  .split('&')
  .reduce(parseKeysValues, {})
}

export function setQuerystring (url: Url, key: string, value?: string | number) {
  const [ href, qs ] = url.split('?') as [ typeof url, string ]
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

type QueryObj = Record<string, unknown>
export function buildPath (pathname: Url, queryObj?: QueryObj) {
  queryObj = removeUndefined(queryObj)
  if ((queryObj == null) || isEmpty(queryObj)) return pathname

  let queryString = ''

  for (let [ key, value ] of objectEntries(queryObj)) {
    if (isObject(value)) {
      value = encodeURIComponent(JSON.stringify(value))
    }
    queryString += `&${key}=${value}`
  }

  return (pathname + '?' + queryString.slice(1)) as typeof pathname
}

export const currentRoute = () => location.pathname.slice(1)

export const currentRouteWithQueryString = () => location.pathname.slice(1) + location.search

export const currentSection = () => routeSection(currentRoute())

function parseKeysValues (queryObj: QueryObj, nextParam: string) {
  const pairs = nextParam.split('=')
  const [ key, value ] = pairs
  if ((key?.length > 0) && (value != null)) {
    // Try to parse the value, allowing JSON strings values
    // like data={%22wdt:P50%22:[%22wd:Q535%22]}
    let parsedValue = permissiveJsonParse(decodeURIComponent(value))
    // If a number string was parsed into a number, make it a string again
    // so that the output stays predictible
    if (isNumber(parsedValue)) parsedValue = parsedValue.toString()
    queryObj[key] = parsedValue
  }

  return queryObj
}

function permissiveJsonParse (input: string) {
  if (input[0] === '{' || input[0] === '[') {
    try {
      return JSON.parse(input)
    } catch (err) {
      if (err.name !== 'SyntaxError') throw err
      return input
    }
  } else {
    return input
  }
}

function removeUndefined (obj?: QueryObj) {
  const newObj = {}
  for (const key in obj) {
    const value = obj[key]
    if (value != null) newObj[key] = value
  }
  return newObj
}
