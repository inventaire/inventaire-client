Welcome = require 'modules/welcome/views/welcome'
ErrorView = require 'modules/general/views/error'
CallToConnection = require 'modules/general/views/call_to_connection'
initQuerystringActions = require 'modules/general/lib/querystring_actions'
DonateMenu = require 'modules/general/views/donate_menu'
FeedbackMenu = require 'modules/general/views/feedback_menu'

module.exports =
  define: (module, app, Backbone, Marionette, $, _)->
    Router = Marionette.AppRouter.extend
      appRoutes:
        '(home)': 'showHome'
        'welcome(/)': 'showWelcome'
        'about(/)': 'showWelcome'
        'donate(/)': 'showDonate'
        'feedback(/)': 'showFeedback'
        'me(/)': 'showMainUser'
        '*route': 'notFound'

    app.addInitializer -> new Router { controller: API }

  initialize: ->
    app.reqres.setHandlers
      'require:loggedIn': requireLoggedIn
      'require:admin:rights': requireAdminRights

    app.commands.setHandlers
      'show:home': API.showHome
      'show:welcome': API.showWelcome
      'show:error:missing': showErrorMissing
      'show:error:other': showOtherError
      'show:offline:error': showOfflineError
      'show:call:to:connection': showCallToConnection
      'show:error:cookieRequired': showErrorCookieRequired
      'show:signup:redirect': showSignupRedirect
      'show:login:redirect': showLoginRedirect

    # should be run before app start to access the unmodifed url
    initQuerystringActions()

API =
  showHome: ->
    if app.user.loggedIn then app.execute 'show:inventory:general'
    else app.execute 'show:welcome'

  notFound: (route)->
    _.log route, 'route:notFound'
    app.execute 'show:error:missing'

  showWelcome: ->
    app.layout.main.show new Welcome
    app.navigate 'welcome'

  showDonate: -> showMenuStandalone DonateMenu, 'donate'
  showFeedback: -> showMenuStandalone FeedbackMenu, 'feedback'
  showMainUser: -> app.execute 'show:inventory:main:user'

requireLoggedIn = (route)->
  if app.user.loggedIn then return true
  else
    app.execute 'show:login'
    prepareLoginRedirect route
    return false

requireAdminRights = ->
  if app.user.get('admin') then return true
  else
    showErrorNotAdmin()
    return false

showAuthRedirect = (action, route)->
  route or= _.currentRoute()
  app.execute "show:#{action}"
  if route not in noRedirectionRequired
    prepareLoginRedirect route

prepareLoginRedirect = (route)->
  # the route shouldn't have the first '/'. ex: inventory/georges
  route = route.replace /^\//, ''
  app.execute 'prepare:login:redirect', route

noRedirectionRequired = [
  'welcome'
]

showSignupRedirect = showAuthRedirect.bind null, 'signup'
showLoginRedirect = showAuthRedirect.bind null, 'login'

showErrorMissing = ->
  showError
    name: 'missing'
    icon: 'warning'
    header: _.I18n 'oops'
    message: _.i18n "this resource doesn't exist or you don't have the right to access it"
    context: location.pathname

showErrorNotAdmin = ->
  showError
    name: 'not_admin'
    icon: 'warning'
    header: _.I18n 'oops'
    message: _.i18n "this resource requires to have admin rights to access it"
    context: location.pathname

showOtherError = (err, label)->
  _.type err, 'object'
  _.error err, label
  showError
    name: 'other'
    icon: 'bolt'
    header: _.I18n 'error'
    message: err.message

showOfflineError = ->
  showError
    name: 'offline'
    icon: 'plug'
    header: _.i18n "can't reach the server"

showErrorCookieRequired = (command)->
  showError
    name: 'cookie-required'
    icon: 'cog'
    header: _.I18n 'cookies are disabled'
    message: _.i18n 'cookies_are_required'
    redirection:
      text: _.I18n 'retry'
      classes: 'dark-grey'
      buttonAction: ->
        if command? then app.execute command
        else location.href = location.href

showError = (options)->
  app.layout.main.show new ErrorView options
  # When the logic leading to the error didn't trigger a new 'navigate' action,
  # hitting 'Back' would bring back two pages before, so we can pass a navigate
  # option to prevent it
  if options.navigate then app.navigate "error/#{options.name}"

showCallToConnection = (message)->
  app.layout.modal.show new CallToConnection
    connectionMessage: message

showMenuStandalone = (Menu, titleKey)->
  app.layout.main.show new Menu { standalone: true }
  app.navigate titleKey, { metadata: { title: _.i18n(titleKey) } }
