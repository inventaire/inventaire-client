import { currentRouteWithQueryString, parseQuery, type ProjectRootRelativeUrl } from '#app/lib/location'
import { clearMetadata, updateRouteMetadata, type MetadataUpdate } from '#app/lib/metadata/update'
import { scrollToElement } from '#app/lib/screen'
import { dropLeadingSlash } from '#app/lib/utils'
import { commands, vent } from '#app/radio'
import { newError } from './lib/error.ts'
import log_ from './lib/loggers.ts'
import { keepQuerystringParameter } from './lib/querystring_helpers.ts'
import { loadUrl, startRouter } from './lib/router.ts'
import { updateI18nLang } from './modules/user/lib/i18n.ts'
import type { UserLang } from './lib/languages.ts'

let initialUrlNavigateAlreadyCalled = false
let lastNavigateTimestamp = 0

interface NavigateOptions {
  replace?: boolean
  trigger?: boolean
  pageSectionElement?: HTMLElement
  preventScrollTop?: boolean
  metadata?: MetadataUpdate | Promise<MetadataUpdate>
}

const historyLast = []

function navigate (route: string, options: NavigateOptions = {}) {
  // Close the modal if it was open
  commands.execute('modal:close')
  // Update metadata before testing if the route changed
  // so that a call from a router action would trigger a metadata update
  // but not affect the history (due to the early return hereafter)
  const metadata = 'metadata' in options ? options.metadata : {}
  updateRouteMetadata(route, metadata)
  // Easing code mutualization by firing app.navigate, even when the module
  // simply reacted to the requested URL
  if (route === currentRouteWithQueryString()) {
    // Trigger a route event for the first URL, so that event listeners can update accordingly
    if (!initialUrlNavigateAlreadyCalled) {
      vent.trigger('route:change')
      initialUrlNavigateAlreadyCalled = true
    }
    return
  }

  // routeSection relies on the route not starting by a slash.
  // It can't just thrown an error as pathnames commonly require to start
  // by a slash to avoid being interpreted as relative pathnames
  route = dropLeadingSlash(route)
  vent.trigger('route:change')
  route = keepQuerystringParameter(route)

  const routeWithLeadingSlash = `/${route}`
  if (historyLast[0] === routeWithLeadingSlash) return
  historyLast.unshift(routeWithLeadingSlash)

  // Replace last route in history when several navigation happen quickly
  // so that hitting "Previous" correctly brings back to the last page
  // where a user action triggered a page change
  const now = Date.now()
  if (now < lastNavigateTimestamp + 200) options.replace = true
  lastNavigateTimestamp = now

  if (options.replace) {
    history.replaceState(null, null, routeWithLeadingSlash)
  } else {
    history.pushState(null, null, routeWithLeadingSlash)
  }
  if (options.trigger) loadUrl(routeWithLeadingSlash)
  const { pageSectionElement, preventScrollTop } = options
  if (pageSectionElement) {
    scrollToElement(pageSectionElement)
  } else if (!preventScrollTop) {
    scrollToPageTop()
  }
}

function navigateAndLoad (route: ProjectRootRelativeUrl, options: NavigateOptions = {}) {
  options.trigger = true
  navigate(route, options)
}

// Used by firefox-headless-prerender
async function clearMetadataNavigateAndLoad (route: ProjectRootRelativeUrl, options: NavigateOptions = {}) {
  const { lang = 'en' } = parseQuery(route.split('?')[1])
  await updateI18nLang(lang as UserLang)
  navigateAndLoad(route, options)
  clearMetadata()
}

function navigateReplace (route: ProjectRootRelativeUrl, options: NavigateOptions = {}) {
  options.replace = true
  navigate(route, options)
}

const app = {
  navigate,
  navigateAndLoad,
  clearMetadataNavigateAndLoad,
  navigateReplace,

  start,
} as const

async function start () {
  // Import async to let AppLayout dependencies depending on the app object
  const { initAppLayout } = await import('#app/init_app_layout')
  initAppLayout()
  startRouter()
  window.addEventListener('popstate', navigateBack)
}

function navigateBack (event: PopStateEvent) {
  if (event.target && 'location' in event.target) {
    const { pathname, search } = event.target.location as Location
    const route = search ? `${pathname}${search}` : pathname
    loadUrl(route)
  } else {
    log_.error(newError('can not navigate back', 500, { event }))
  }
}

export function canGoBack () {
  return historyLast.length > 1
}

// Required by firefox-headless-prerender
window.app = app

export default app

const scrollToPageTop = () => window.scrollTo(0, 0)
