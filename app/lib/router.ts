import { objectEntries } from './utils'

// Router logic borrowing from Backbone.Router and @jgarber/routerrouter

export type RouteControllerNames = Record<string, string>
export type RouteAction = (...args: string[]) => void | Promise<void>
export type RouteControllers = Record<string, RouteAction>

export function addRoutes (newRouteControllerNames: RouteControllerNames, controllers: RouteControllers) {
  for (const [ route, controllerName ] of objectEntries(newRouteControllerNames)) {
    const action = controllers[controllerName]
    setRoute(route, action)
  }
}

const handlers: [ RegExp, RouteAction ][] = []

function setRoute (route: string | RegExp, action: RouteAction) {
  if (!(route instanceof RegExp)) {
    route = routeToRegExp(route)
  }
  handlers.push([ route, action ])
}

// Given a RegExp'ed `route` and a `path`, return the array of extracted
// and decoded parameters. Empty or unmatched parameters will be treated
// as `null` to normalize cross-browser behavior.
function extractParameters (routeRegex: RegExp, pathname: string) {
  return routeRegex.exec(pathname).slice(1).map(parameter => {
    return parameter ? decodeURIComponent(parameter) : null
  })
}

// Convert a route string into a regular expression suitable for matching
// against the current location's `pathname`.
function routeToRegExp (route: string) {
  route = route
    // escape RegExp reserved characters
    .replaceAll(/[$.|]+/g, '\\$&')
    // replace optional parameters with RegExp
    .replaceAll(/\((.+?)\)/g, '(?:$1)?')
    // replace named parameters with RegExp
    .replaceAll(/:\w+/g, '([^/]+)')
    // replace wildcard parameters with RegExp
    .replaceAll(/\*(\w+)?/g, '(.+?)')

  return new RegExp(`^${route}$`)
}

export function loadUrl (pathname: string) {
  pathname = decodeURIComponent(pathname)
  for (const [ routeRegex, action ] of handlers) {
    if (routeRegex.test(pathname)) return action(...extractParameters(routeRegex, pathname))
  }
  throw new Error('route not found')
}

export function startRouter () {
  loadUrl(location.pathname)
}
