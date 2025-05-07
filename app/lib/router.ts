import { objectEntries } from './utils'

// Router logic borrowing from Backbone.Router and @jgarber/routerrouter

export type RouteControllerNames = Record<string, string>
export type RouteAction = (...args: string[]) => void | Promise<void>
export type RouteControllers = Record<string, RouteAction>

export function addRoutes (newRouteControllerNames: RouteControllerNames, controllers: RouteControllers) {
  for (const [ route, controllerName ] of objectEntries(newRouteControllerNames).reverse()) {
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

function extractParameters (routeRegex: RegExp, pathname: string) {
  return routeRegex.exec(pathname).slice(1).map(parameter => {
    return parameter ? decodeURIComponent(parameter) : null
  })
}

// Adapted from https://github.com/jashkenas/backbone/blob/8f0285f/backbone.js#L1755-L1762
function routeToRegExp (route: string) {
  route = route
    // Escape
    .replace(/[-{}[\]+?.,\\^$|#\s]/g, '\\$&')
    // Optional  parameter
    .replace(/\((.*?)\)/g, '(?:$1)?')
    // Named parameter
    .replace(/(\(\?)?:\w+/g, (match, optional) => optional ? match : '([^/?]+)')
    // Splat parameter
    .replace(/\*\w+/g, '([^?]*?)')
  return new RegExp('^' + route + '(?:\\?([\\s\\S]*))?$')
}

export function loadUrl (pathname: string) {
  pathname = decodeURIComponent(pathname)
  for (const [ routeRegex, action ] of handlers) {
    if (routeRegex.test(pathname)) {
      return action(...extractParameters(routeRegex, pathname))
    }
  }
  throw new Error('route not found')
}

export function startRouter () {
  // Reverse to let loadUrl iterate handlers by priority order
  handlers.reverse()
  loadUrl(location.pathname + location.search)
}
