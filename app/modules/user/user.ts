import { API } from '#app/api/api'
import app from '#app/app'
import { assertString } from '#app/lib/assert_types'
import { newError } from '#app/lib/error'
import { parseQuery } from '#app/lib/location'
import preq from '#app/lib/preq'
import { I18n } from '#user/lib/i18n'
import auth from './lib/auth.ts'
import { initMainUser } from './lib/main_user.ts'

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
      },
    })

    new Router({ controller })

    initMainUser()
    auth()

    app.commands.setHandlers({
      'show:signup': controller.showSignup,
      'show:login': controller.showLogin,
      'show:forgot:password': controller.showForgotPassword,
    })
  },
}

function showAuth (name: string, label: string, Component, options: string | object) {
  if (!navigator.cookieEnabled) {
    return app.execute('show:error:cookieRequired', `show:${name}`)
  }

  if (app.user.loggedIn) return app.execute('show:home')

  if (typeof options === 'string') options = parseQuery(options)
  app.layout.showChildComponent('main', Component, { props: options })
  app.navigate(name, { metadata: { title: I18n(label) } })
}

// beware that app.layout is undefined when User.define is fired
// app.layout should thus appear only in callbacks
const controller = {
  // Options might be passed as an object when called by `app.execute('show:signup)`
  async showSignup (options: string | object) {
    const { default: Signup } = await import('./components/signup.svelte')
    showAuth('signup', 'Create account', Signup, options)
  },

  async showLogin (options: string | object) {
    const { default: Login } = await import('./components/login.svelte')
    showAuth('login', 'login', Login, options)
  },

  async showForgotPassword (querystring: string) {
    const { default: ForgotPassword } = await import('./components/forgot_password.svelte')
    const { resetPasswordFail, email } = parseQuery(querystring)
    app.layout.showChildComponent('main', ForgotPassword, {
      props: { resetPasswordFail, email },
    })
    app.navigate('login/forgot-password', {
      metadata: {
        title: I18n('forgot password'),
      },
    })
  },

  async showResetPassword () {
    const { default: ResetPassword } = await import('./components/reset_password.svelte')
    if (app.user.loggedIn) {
      app.layout.showChildComponent('main', ResetPassword)
      app.navigate('login/reset-password', {
        metadata: {
          title: I18n('reset password'),
        },
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
      assertString(query.client_id)
      const client = await getOAuthClient(query.client_id)
      const { default: AuthorizeMenu } = await import('./components/authorize_menu.svelte')
      app.layout.showChildComponent('main', AuthorizeMenu, { props: { query, client } })
    } catch (err) {
      app.execute('show:error', err)
    }
  },

  logout () { app.execute('logout') },
}

const getOAuthClient = async clientId => {
  const { clients } = await preq.get(API.oauth.clients.byId(clientId))
  return clients[clientId]
}

const validateAuthorizationRequest = query => {
  const { state, scope, client_id: clientId, redirect_uri: redirectUri } = query

  if (!clientId) throw invalidAuthorizationRequest('missing client_id')
  if (!scope) throw invalidAuthorizationRequest('missing scope')
  if (!state) throw invalidAuthorizationRequest('missing state')
  if (!redirectUri) throw invalidAuthorizationRequest('missing redirect_uri')
}

const invalidAuthorizationRequest = (reason, query?) => {
  return newError(`invalid authorization request: ${reason}`, 400, { reason, query })
}
