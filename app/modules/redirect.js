import assert_ from 'lib/assert_types'
import log_ from 'lib/loggers'
import { I18n, i18n } from 'modules/user/lib/i18n'
import initQuerystringActions from 'modules/general/lib/querystring_actions'
import { currentRoute } from 'lib/location'
import { setPrerenderStatusCode } from 'lib/metadata/update'

export default {
  define () {
    const Router = Marionette.AppRouter.extend({
      appRoutes: {
        '(home)': 'showHome',
        'welcome(/)': 'showWelcome',
        'about(/)': 'showWelcome',
        'donate(/)': 'showDonate',
        'feedback(/)': 'showFeedback',
        'me(/)': 'showMainUser',
        'svelte-test': 'showSvelteTest',
        '*route': 'notFound'
      }
    })

    app.addInitializer(() => new Router({ controller: API }))
  },

  initialize () {
    app.reqres.setHandlers({
      'require:loggedIn': requireLoggedIn,
      'require:admin:access': requireAdminAccess,
      'require:dataadmin:access': requireDataadminAccess
    })

    app.commands.setHandlers({
      'show:home': API.showHome,
      'show:welcome': API.showWelcome,
      'show:error': showErrorByStatus,
      'show:error:missing': showErrorMissing,
      'show:error:other': showOtherError,
      'show:offline:error': showOfflineError,
      'show:call:to:connection': showCallToConnection,
      'show:error:cookieRequired': showErrorCookieRequired,
      'show:signup:redirect': showSignupRedirect,
      'show:login:redirect': showLoginRedirect
    })

    // Should be run before app start to access the unmodifed url
    initQuerystringActions()
  }
}

const API = {
  showHome () {
    if (app.user.loggedIn) {
      app.execute('show:inventory:main:user')
    } else {
      app.execute('show:welcome')
    }
  },

  async showSvelteTest () {
    const { default: SvelteTest } = await import('./test.svelte')
    new SvelteTest({
      target: document.querySelector('main'),
      data: {
        name: 'world'
      }
    })
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
    const { default: Welcome } = await import('modules/welcome/views/welcome')
    app.layout.main.show(new Welcome())
    app.navigate('welcome')
  },

  async showDonate () {
    const { default: DonateMenu } = await import('modules/general/views/donate_menu')
    showMenuStandalone(DonateMenu, 'donate')
  },

  async showFeedback () {
    const { default: FeedbackMenu } = await import('modules/general/views/feedback_menu')
    showMenuStandalone(FeedbackMenu, 'feedback')
  },

  showMainUser () { app.execute('show:inventory:main:user') }
}

const requireLoggedIn = function (route) {
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

const requireAdminAccess = function () {
  setPrerenderStatusCode(401)
  if (app.user.hasAdminAccess) {
    return true
  } else {
    showErrorNotAdmin()
    return false
  }
}

const requireDataadminAccess = function () {
  setPrerenderStatusCode(401)
  if (app.user.hasDataadminAccess) {
    return true
  } else {
    showErrorNotAdmin()
    return false
  }
}

const showAuthRedirect = function (action, route) {
  const redirect = getRedirectedRoute(route)
  app.execute(`show:${action}`, { redirect })
}

const getRedirectedRoute = function (route) {
  if (!route) route = currentRoute()
  if (noRedirectionRequired.includes(route)) return
  return route
}

const noRedirectionRequired = [
  'welcome'
]

const showSignupRedirect = showAuthRedirect.bind(null, 'signup')
const showLoginRedirect = showAuthRedirect.bind(null, 'login')

const showErrorByStatus = function (err, label) {
  if (err.statusCode === 404) {
    return showErrorMissing()
  } else {
    return showOtherError(err, label)
  }
}

const showErrorMissing = () => showError({
  name: 'missing',
  icon: 'warning',
  header: I18n('oops'),
  message: i18n("this resource doesn't exist or you don't have the right to access it"),
  context: location.pathname,
  statusCode: 404
})

const showErrorNotAdmin = () => showError({
  name: 'not_admin',
  icon: 'warning',
  header: I18n('oops'),
  message: i18n('this resource requires to have admin rights to access it'),
  context: location.pathname,
  statusCode: 403
})

const showOtherError = function (err, label) {
  assert_.object(err)
  log_.error(err, label)
  return showError({
    name: 'other',
    icon: 'bolt',
    header: I18n('error'),
    message: err.message,
    context: err.context,
    statusCode: err.statusCode
  })
}

const showOfflineError = () => showError({
  name: 'offline',
  icon: 'plug',
  header: i18n("can't reach the server")
})

const showErrorCookieRequired = command => showError({
  name: 'cookie-required',
  icon: 'cog',
  header: I18n('cookies are disabled'),
  message: i18n('cookies_are_required'),
  redirection: {
    text: I18n('retry'),
    classes: 'dark-grey',
    buttonAction () {
      if (command != null) app.execute(command)
    }
  }
})

const showError = async options => {
  const { default: ErrorView } = await import('modules/general/views/error')
  app.layout.main.show(new ErrorView(options))
  setPrerenderStatusCode(options.statusCode)
  // When the logic leading to the error didn't trigger a new 'navigate' action,
  // hitting 'Back' would bring back two pages before, so we can pass a navigate
  // option to prevent it
  if (options.navigate) app.navigate(`error/${options.name}`)
}

const showCallToConnection = async message => {
  const { default: CallToConnection } = await import('modules/general/views/call_to_connection')
  app.layout.modal.show(new CallToConnection({ connectionMessage: message }))
}

const showMenuStandalone = function (Menu, titleKey) {
  app.layout.main.show(new Menu({ standalone: true }))
  app.navigate(titleKey, { metadata: { title: i18n(titleKey) } })
}
