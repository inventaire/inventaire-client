import app from '#app/app'
import assert_ from '#app/lib/assert_types'
import type { ContextualizedError } from '#app/lib/error'
import { currentRoute } from '#app/lib/location'
import log_ from '#app/lib/loggers'
import { setPrerenderStatusCode, isPrerenderSession } from '#app/lib/metadata/update'
import { I18n, i18n } from '#user/lib/i18n'
import { showMainUserProfile } from '#users/users'

export default {
  initialize () {
    const Router = Marionette.AppRouter.extend({
      appRoutes: {
        '(home)': 'showHome',
        'welcome(/)': 'showWelcome',
        'about(/)': 'showWelcome',
        'donate(/)': 'showDonate',
        'feedback(/)': 'showFeedback',
        'me(/)': 'showMainUser',
        '*route': 'notFound',
      },
    })

    new Router({ controller })

    app.reqres.setHandlers({
      'require:loggedIn': requireLoggedIn,
      'require:admin:access': requireAdminAccess,
      'require:dataadmin:access': requireDataadminAccess,
    })

    app.commands.setHandlers({
      'show:home': controller.showHome,
      'show:welcome': controller.showWelcome,
      'show:error': showErrorByStatus,
      'show:error:missing': showErrorMissing,
      'show:error:other': showOtherError,
      'show:offline:error': showOfflineError,
      'show:call:to:connection': showCallToConnection,
      'show:error:cookieRequired': showErrorCookieRequired,
      'show:signup:redirect': showSignupRedirect,
      'show:login:redirect': showLoginRedirect,
    })
  },
}

const controller = {
  showHome () {
    if (app.user.loggedIn) {
      showMainUserProfile()
    } else {
      app.execute('show:welcome')
    }
  },

  notFound (route) {
    const cleanedRoute = route
      .replace(/^\//, '')
      .replace(/\/\//g, '/')
    // Attempt to recover cases where the route contains a double slash
    if (cleanedRoute !== route) {
      log_.info({ route, cleanedRoute }, 'route:recovered')
      app.navigateReplace(cleanedRoute, { trigger: true })
    } else {
      log_.info(route, 'route:notFound')
      app.execute('show:error:missing')
    }
  },

  async showWelcome () {
    const { default: WelcomeLayout } = await import('#welcome/components/welcome_layout.svelte')
    app.layout.showChildComponent('main', WelcomeLayout)
    app.navigate('welcome', {
      metadata: {
        title: i18n('Inventaire - your friends and communities are your best library'),
        description: i18n('Make the inventory of your books and mutualize with your friends and communities into an infinite library!'),
      },
    })
  },

  async showDonate () {
    redirectOutside('https://wiki.inventaire.io/wiki/Funding')
  },

  async showFeedback () {
    const { default: FeedbackMenu } = await import('#general/views/feedback_menu')
    showMenuStandalone(FeedbackMenu, 'feedback')
  },

  showMainUser () { app.execute('show:inventory:main:user') },
}

function requireLoggedIn (route: string) {
  setPrerenderStatusCode(401)
  assert_.string(route)
  if (app.user.loggedIn) {
    return true
  } else {
    const redirect = getRedirectedRoute(route)
    app.execute('show:login', { redirect })
    return false
  }
}

function requireAdminAccess () {
  setPrerenderStatusCode(401)
  if (app.user.hasAdminAccess) {
    return true
  } else {
    showErrorNotAdmin()
    return false
  }
}

function requireDataadminAccess () {
  setPrerenderStatusCode(401)
  if (app.user.hasDataadminAccess) {
    return true
  } else {
    showErrorNotAdmin()
    return false
  }
}

function showAuthRedirect (action: string, route: string) {
  const redirect = getRedirectedRoute(route)
  app.execute(`show:${action}`, { redirect })
}

function getRedirectedRoute (route: string) {
  if (!route) route = currentRoute()
  if (noRedirectionRequired.includes(route)) return
  return route
}

const noRedirectionRequired = [
  'welcome',
]

const showSignupRedirect = showAuthRedirect.bind(null, 'signup')
const showLoginRedirect = showAuthRedirect.bind(null, 'login')

function showErrorByStatus (err: ContextualizedError, label: string) {
  if (err.statusCode === 404) {
    return showErrorMissing()
  } else {
    return showOtherError(err, label)
  }
}

function showErrorMissing (params: { pathname?: string } = {}) {
  const { pathname = location.pathname } = params
  if (pathname !== location.pathname) app.navigate(pathname)
  showError({
    name: 'missing',
    icon: 'warning',
    header: I18n('oops'),
    message: I18n("this resource doesn't exist or you don't have the right to access it"),
    context: pathname,
    statusCode: 404,
  })
}

const showErrorNotAdmin = () => showError({
  name: 'not_admin',
  icon: 'warning',
  header: I18n('oops'),
  message: I18n('this resource requires to have admin rights to access it'),
  context: location.pathname,
  statusCode: 403,
})

function showOtherError (err: ContextualizedError, label: string) {
  assert_.object(err)
  log_.error(err, label)
  return showError({
    name: 'other',
    icon: 'bolt',
    header: I18n('error'),
    message: err.message,
    context: err.context,
    statusCode: err.statusCode,
  })
}

const showOfflineError = () => showError({
  name: 'offline',
  icon: 'plug',
  header: I18n("can't reach the server"),
})

const showErrorCookieRequired = (command: string) => showError({
  name: 'cookie-required',
  icon: 'cog',
  header: I18n('cookies are disabled'),
  message: I18n('cookies_are_required'),
  redirection: {
    text: I18n('retry'),
    classes: 'dark-grey',
    buttonAction () {
      if (command != null) app.execute(command)
    },
  },
})

interface ShowErrorOptions {
  name: string
  icon: string
  header: string
  message?: string
  context?: string | ContextualizedError['context']
  statusCode?: ContextualizedError['statusCode']
  navigate?: boolean
  redirection?: {
    text: string
    classes: string
    buttonAction: () => void
  }
}
async function showError (options: ShowErrorOptions) {
  const { default: ErrorView } = await import('#general/views/error')
  app.execute('modal:close')
  app.layout.showChildView('main', new ErrorView(options))
  setPrerenderStatusCode(options.statusCode)
  // When the logic leading to the error didn't trigger a new 'navigate' action,
  // hitting 'Back' would bring back two pages before, so we can pass a navigate
  // option to prevent it
  if (options.navigate) app.navigate(`error/${options.name}`)
}

async function showCallToConnection (message) {
  const { default: CallToConnection } = await import('#general/views/call_to_connection')
  app.layout.showChildView('modal', new CallToConnection({ connectionMessage: message }))
}

function showMenuStandalone (Menu, titleKey) {
  app.layout.showChildView('main', new Menu({ standalone: true }))
  app.navigate(titleKey, { metadata: { title: i18n(titleKey) } })
}

function redirectOutside (url) {
  setPrerenderStatusCode(302)
  if (!isPrerenderSession) {
    location.href = url
  }
}
