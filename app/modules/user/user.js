import { I18n } from '#user/lib/i18n'
import error_ from '#lib/error'
import initMainUser from './lib/init_main_user.js'
import auth from './lib/auth.js'
import userUpdate from './lib/user_update.js'
import preq from '#lib/preq'

export default {
  initialize () {
    const Router = Marionette.AppRouter.extend({
      appRoutes: {
        'signup(/)': 'showSignup',
        'login(/)': 'showLogin',
        'login/forgot-password(/)': 'showForgotPassword',
        'login/reset-password(/)': 'showResetPassword',
        'logout(/)': 'logout',
        'authorize(/)': 'showAuthorizeMenu',
      }
    })

    new Router({ controller: API })

    initMainUser(app)
    auth(app)
    userUpdate(app)

    app.commands.setHandlers({
      'show:signup': API.showSignup,
      'show:login': API.showLogin,
      'show:forgot:password': API.showForgotPassword
    })
  }
}

const showAuth = (name, label, View, options) => {
  if (!navigator.cookieEnabled) {
    return app.execute('show:error:cookieRequired', `show:${name}`)
  }

  if (app.user.loggedIn) return app.execute('show:home')

  app.layout.showChildView('main', new View(options))
  app.navigate(name, { metadata: { title: I18n(label) } })
}

// beware that app.layout is undefined when User.define is fired
// app.layout should thus appear only in callbacks
const API = {
  async showSignup (options) {
    const { default: Signup } = await import('./views/signup.js')
    showAuth('signup', 'sign up', Signup, options)
  },

  async showLogin (options) {
    const { default: Login } = await import('./views/login.js')
    showAuth('login', 'login', Login, options)
  },

  async showForgotPassword (options) {
    const { default: ForgotPassword } = await import('./views/forgot_password.js')
    app.layout.showChildView('main', new ForgotPassword(options))
    app.navigate('login/forgot-password', {
      metadata: {
        title: I18n('forgot password')
      }
    })
  },

  async showResetPassword () {
    const { default: ResetPassword } = await import('./views/reset_password.js')
    if (app.user.loggedIn) {
      app.layout.showChildView('main', new ResetPassword())
      app.navigate('login/reset-password', {
        metadata: {
          title: I18n('reset password')
        }
      })
    } else {
      app.execute('show:forgot:password')
    }
  },

  async showAuthorizeMenu () {
    const query = app.request('querystring:get:all')

    try {
      validateAuthorizationRequest(query)
      const postLoginRedirection = window.location.pathname + window.location.search
      if (!(app.request('require:loggedIn', postLoginRedirection))) return
      const client = await getOAuthClient(query.client_id)
      const { default: AuthorizeMenu } = await import('./views/authorize_menu.js')
      app.layout.showChildView('main', new AuthorizeMenu({ query, client }))
    } catch (err) {
      app.execute('show:error', err)
    }
  },

  logout () { app.execute('logout') }
}

const getOAuthClient = async clientId => {
  const { clients } = await preq.get(app.API.oauth.clients.byId(clientId))
  return clients[clientId]
}

const validateAuthorizationRequest = query => {
  const { state, scope, client_id: clientId, redirect_uri: redirectUri } = query

  if (!clientId) throw invalidAuthorizationRequest('missing client_id')
  if (!scope) throw invalidAuthorizationRequest('missing scope')
  if (!state) throw invalidAuthorizationRequest('missing state')
  if (!redirectUri) throw invalidAuthorizationRequest('missing redirect_uri')
}

const invalidAuthorizationRequest = (reason, query) => {
  return error_.new(`invalid authorization request: ${reason}`, 400, { reason, query })
}
