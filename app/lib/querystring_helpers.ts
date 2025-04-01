import app from '#app/app'
import { parseQuery, buildPath, setQuerystring, routeSection, type ProjectRootRelativeUrl } from '#app/lib/location'
import { commands } from '#app/radio'
import type { RelativeUrl } from '#server/types/common'
import allowPersistantQuery from './allow_persistant_query.ts'

export default function () {
  commands.setHandlers({
    'querystring:set': setParameter,
    'querystring:remove': removeParameter,
  })
}

export function getQuerystringParameter (key: string) {
  const value = getAllQuerystringParameters()?.[key]
  // Parsing boolean strings
  if (value === 'true') return true
  if (value === 'false') return false
  return value
}

function setParameter (key, value) {
  // Setting the value to 'null' and not just the null keyword
  // allows to have the null value passed to the keep function (called by app.navigate),
  // thus unsetting the desired key
  if (value == null) value = 'null'
  updateParameter(key, value)
}

const removeParameter = key => updateParameter(key, null)

function updateParameter (key, value) {
  const currentPath = (window.location.pathname + window.location.search) as RelativeUrl
  const updatedPath = setQuerystring(currentPath, key, value)
  app.navigateReplace(updatedPath)
}

/** report persistant querystrings from the current route to the next one */
export function keepQuerystringParameter (newRoute: ProjectRootRelativeUrl) {
  // get info on new route
  let newQuery;
  [ newRoute, newQuery ] = newRoute.split('?')
  newQuery = parseQuery(newQuery)

  const currentQuery = getAllQuerystringParameters()
  const keptQuery = {}

  const newRouteSection = routeSection(newRoute)

  for (const k in currentQuery) {
    const v = currentQuery[k]
    const test = allowPersistantQuery[k]
    // discard queries that have no tests in allowPersistantQuery
    if (test?.(newRouteSection)) {
      keptQuery[k] = v
    }
  }

  // extend persisting current parameters with new parameters
  newQuery = Object.assign(keptQuery, newQuery)
  return buildPath(newRoute, newQuery)
}

export const getAllQuerystringParameters = () => parseQuery(location.search)
