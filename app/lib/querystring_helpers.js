import allowPersistantQuery from './allow_persistant_query'
import { parseQuery, buildPath, setQuerystring, routeSection } from '#lib/location'

export default function () {
  app.reqres.setHandlers({
    'querystring:get': get,
    'querystring:get:all': getQuery,
    'querystring:keep': keep
  })

  app.commands.setHandlers({
    'querystring:set': set
  })
}

export const get = function (key) {
  const value = getQuery()?.[key]
  // Parsing boolean strings
  if (value === 'true') return true
  if (value === 'false') return false
  return value
}

const set = function (key, value) {
  // Setting the value to 'null' and not just the null keyword
  // allows to have the null value passed to the keep function (called by app.navigate),
  // thus unsetting the desired key
  if (value == null) value = 'null'

  // omit the first character: '/'
  const currentPath = window.location.pathname.slice(1) + window.location.search
  const updatedPath = setQuerystring(currentPath, key, value)
  app.navigateReplace(updatedPath)
}

// report persistant querystrings from the current route to the next one
const keep = function (newRoute) {
  // get info on new route
  let newQuery;
  [ newRoute, newQuery ] = newRoute.split('?')
  newQuery = parseQuery(newQuery)

  const currentQuery = getQuery()
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
  newQuery = _.extend(keptQuery, newQuery)
  return buildPath(newRoute, newQuery)
}

const getQuery = () => parseQuery(window.location.search)
