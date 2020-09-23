/* eslint-disable
    import/no-duplicates,
    no-return-assign,
    no-self-assign,
    no-undef,
    no-unused-vars,
    no-var,
    prefer-arrow/prefer-arrow-functions,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
import Welcome from 'modules/welcome/views/welcome'
import ErrorView from 'modules/general/views/error'
import CallToConnection from 'modules/general/views/call_to_connection'
import initQuerystringActions from 'modules/general/lib/querystring_actions'
import DonateMenu from 'modules/general/views/donate_menu'
import FeedbackMenu from 'modules/general/views/feedback_menu'
import { currentRoute } from 'lib/location'
import updateMetadataNodeType from 'lib/metadata/update_node_type'
import { setPrerenderStatusCode } from 'lib/metadata/update'

export default {
  define (module, app, Backbone, Marionette, $, _) {
    const Router = Marionette.AppRouter.extend({
      appRoutes: {
        '(home)': 'showHome',
        'welcome(/)': 'showWelcome',
        'about(/)': 'showWelcome',
        'donate(/)': 'showDonate',
        'feedback(/)': 'showFeedback',
        'me(/)': 'showMainUser',
        '*route': 'notFound'
      }
    })

    return app.addInitializer(() => new Router({ controller: API }))
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

    // should be run before app start to access the unmodifed url
    return initQuerystringActions()
  }
}

var API = {
  showHome () {
    if (app.user.loggedIn) {
      return app.execute('show:inventory:main:user')
    } else { return app.execute('show:welcome') }
  },

  notFound (route) {
    _.log(route, 'route:notFound')
    return app.execute('show:error:missing')
  },

  showWelcome () {
    app.layout.main.show(new Welcome())
    return app.navigate('welcome')
  },

  showDonate () { return showMenuStandalone(DonateMenu, 'donate') },
  showFeedback () { return showMenuStandalone(FeedbackMenu, 'feedback') },
  showMainUser () { return app.execute('show:inventory:main:user') }
}

var requireLoggedIn = function (route) {
  setPrerenderStatusCode(401)
  _.type(route, 'string')
  if (app.user.loggedIn) {
    return true
  } else {
    const redirect = getRedirectedRoute(route)
    app.execute('show:login', { redirect })
    return false
  }
}

var requireAdminAccess = function () {
  setPrerenderStatusCode(401)
  if (app.user.hasAdminAccess) {
    return true
  } else {
    showErrorNotAdmin()
    return false
  }
}

var requireDataadminAccess = function () {
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
  return app.execute(`show:${action}`, { redirect })
}

var getRedirectedRoute = function (route) {
  if (!route) { route = currentRoute() }
  if (noRedirectionRequired.includes(route)) { return }
  return route
}

var noRedirectionRequired = [
  'welcome'
]

var showSignupRedirect = showAuthRedirect.bind(null, 'signup')
var showLoginRedirect = showAuthRedirect.bind(null, 'login')

var showErrorByStatus = function (err, label) {
  if (err.statusCode === 404) {
    return showErrorMissing()
  } else { return showOtherError(err, label) }
}

var showErrorMissing = () => showError({
  name: 'missing',
  icon: 'warning',
  header: _.I18n('oops'),
  message: _.i18n("this resource doesn't exist or you don't have the right to access it"),
  context: location.pathname,
  statusCode: 404
})

var showErrorNotAdmin = () => showError({
  name: 'not_admin',
  icon: 'warning',
  header: _.I18n('oops'),
  message: _.i18n('this resource requires to have admin rights to access it'),
  context: location.pathname,
  statusCode: 403
})

var showOtherError = function (err, label) {
  _.type(err, 'object')
  _.error(err, label)
  return showError({
    name: 'other',
    icon: 'bolt',
    header: _.I18n('error'),
    message: err.message,
    context: err.context,
    statusCode: err.statusCode
  })
}

var showOfflineError = () => showError({
  name: 'offline',
  icon: 'plug',
  header: _.i18n("can't reach the server")
})

var showErrorCookieRequired = command => showError({
  name: 'cookie-required',
  icon: 'cog',
  header: _.I18n('cookies are disabled'),
  message: _.i18n('cookies_are_required'),
  redirection: {
    text: _.I18n('retry'),
    classes: 'dark-grey',
    buttonAction () {
      if (command != null) {
        return app.execute(command)
      } else { return location.href = location.href }
    }
  }
})

var showError = function (options) {
  app.layout.main.show(new ErrorView(options))
  setPrerenderStatusCode(options.statusCode)
  // When the logic leading to the error didn't trigger a new 'navigate' action,
  // hitting 'Back' would bring back two pages before, so we can pass a navigate
  // option to prevent it
  if (options.navigate) { return app.navigate(`error/${options.name}`) }
}

var showCallToConnection = message => app.layout.modal.show(new CallToConnection({ connectionMessage: message })
)

var showMenuStandalone = function (Menu, titleKey) {
  app.layout.main.show(new Menu({ standalone: true }))
  return app.navigate(titleKey, { metadata: { title: _.i18n(titleKey) } })
}
