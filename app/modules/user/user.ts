import { API } from '#app/api/api'
import app from '#app/app'
import { appLayout } from '#app/init_app_layout'
import { assertString } from '#app/lib/assert_types'
import { newError } from '#app/lib/error'
import { parseQuery } from '#app/lib/location'
import preq from '#app/lib/preq'
import { getAllQuerystringParameters } from '#app/lib/querystring_helpers'
import { addRoutes } from '#app/lib/router'
import { commands, reqres } from '#app/radio'
import { I18n } from '#user/lib/i18n'
import { mainUser } from '#user/lib/main_user'
import auth from './lib/auth.ts'

export default {
  initialize () {
    addRoutes({
      '/signup(/)': 'showSignup',
      '/login(/)': 'showLogin',
      '/login/forgot-password(/)': 'showForgotPassword',
      '/login/reset-password(/)': 'showResetPassword',
      '/logout(/)': 'logout',
      '/authorize(/)': 'showAuthorizeMenu',
    }, controller)

    auth()

    commands.setHandlers({
      'show:signup': controller.showSignup,
      'show:login': controller.showLogin,
      'show:forgot:password': controller.showForgotPassword,
    })
  },
}

function showAuth (name: string, label: string, Component, options: string | object) {
  if (!navigator.cookieEnabled) {
    return commands.execute('show:error:cookieRequired', `show:${name}`)
  }

  if (mainUser) return commands.execute('show:home')

  if (typeof options === 'string') options = parseQuery(options)
  appLayout.showChildComponent('main', Component, { props: options })
  app.navigate(name, { metadata: { title: I18n(label) } })
}

// beware that appLayoutis undefined when User.define is fired
// appLayoutshould thus appear only in callbacks
const controller = {
  // Options might be passed as an object when called by `commands.execute('show:signup)`
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
    appLayout.showChildComponent('main', ForgotPassword, {
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
    if (mainUser) {
      appLayout.showChildComponent('main', ResetPassword)
      app.navigate('login/reset-password', {
        metadata: {
          title: I18n('reset password'),
        },
      })
    } else {
      commands.execute('show:forgot:password')
    }
  },

  async showAuthorizeMenu () {
    const query = getAllQuerystringParameters()

    try {
      validateAuthorizationRequest(query)
      const postLoginRedirection = window.location.pathname + window.location.search
      if (!(reqres.request('require:loggedIn', postLoginRedirection))) return
      assertString(query.client_id)
      const client = await getOAuthClient(query.client_id)
      const { default: AuthorizeMenu } = await import('./components/authorize_menu.svelte')
      appLayout.showChildComponent('main', AuthorizeMenu, { props: { query, client } })
    } catch (err) {
      commands.execute('show:error', err)
    }
  },

  logout () { commands.execute('logout') },
} as const

async function getOAuthClient (clientId: string) {
  const { clients } = await preq.get(API.oauth.clients.byId(clientId))
  return clients[clientId]
}

function validateAuthorizationRequest (query) {
  const { state, scope, client_id: clientId, redirect_uri: redirectUri } = query

  if (!clientId) throw invalidAuthorizationRequest('missing client_id')
  if (!scope) throw invalidAuthorizationRequest('missing scope')
  if (!state) throw invalidAuthorizationRequest('missing state')
  if (!redirectUri) throw invalidAuthorizationRequest('missing redirect_uri')
}

function invalidAuthorizationRequest (reason, query?) {
  return newError(`invalid authorization request: ${reason}`, 400, { reason, query })
}
