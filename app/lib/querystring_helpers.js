/* eslint-disable
    import/no-duplicates,
    no-undef,
    no-var,
    prefer-arrow/prefer-arrow-functions,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
import allowPersistantQuery from './allow_persistant_query'
import { parseQuery, buildPath, setQuerystring, routeSection } from 'lib/location'

export default function (app, _) {
  app.reqres.setHandlers({
    'querystring:get': get,
    'querystring:get:all': getQuery,
    'querystring:keep': keep
  })

  return app.commands.setHandlers({ 'querystring:set': set })
};

var get = function (key) {
  const value = getQuery()?.[key]
  switch (value) {
  // Parsing boolean string
  case 'true': return true
  case 'false': return false
  default: return value
  }
}

var set = function (key, value) {
  // Setting the value to 'null' and not just null allows to have the null value
  // passed to the keep function (called by app.navigate), thus unsetting
  // the desired key
  if (value == null) { value = 'null' }

  // omit the first character: '/'
  const currentPath = window.location.pathname.slice(1) + window.location.search
  const updatedPath = setQuerystring(currentPath, key, value)
  return app.navigateReplace(updatedPath)
}

// report persistant querystrings from the current route to the next one
var keep = function (newRoute) {
  // get info on new route
  let newQuery;
  [ newRoute, newQuery ] = Array.from(newRoute.split('?'))
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

var getQuery = () => parseQuery(window.location.search)
