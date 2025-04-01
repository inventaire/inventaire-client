import RouterRouter from '@jgarber/routerrouter'
import { objectEntries } from './utils'

export type RouteControllerNames = Record<string, string>
export type RouteControllers = Record<string, ((paramA?: string, paramB?: string) => void | Promise<void>)>

const routes: RouteControllers = {}

export function addRoutes (newRouteControllerNames: RouteControllerNames, controllers: RouteControllers) {
  const newRoutes = {}
  for (const [ route, controllerName ] of objectEntries(newRouteControllerNames)) {
    newRoutes[route] = controllers[controllerName]
  }
  Object.assign(routes, newRoutes)
}

export function start () {
  new RouterRouter(routes)
}
