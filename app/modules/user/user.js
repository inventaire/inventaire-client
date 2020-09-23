/* eslint-disable
    import/no-duplicates,
    no-undef,
    no-var,
    prefer-arrow/prefer-arrow-functions,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
import SignupClassic from './views/signup_classic'
import Login from './views/login'
import ForgotPassword from './views/forgot_password'
import ResetPassword from './views/reset_password'

export default {
  define (module, app, Backbone, Marionette, $, _) {
    const Router = Marionette.AppRouter.extend({
      appRoutes: {
        'signup(/)': 'showSignup',
        'login(/)': 'showLogin',
        'login/forgot-password(/)': 'showForgotPassword',
        'login/reset-password(/)': 'showResetPassword',
        'logout(/)': 'logout'
      }
    })

    app.addInitializer(() => new Router({ controller: API }))

    require('./lib/init_main_user')(app)
    require('./lib/auth')(app)
    require('./lib/user_listings')(app)
    require('./lib/user_update')(app)

    return app.commands.setHandlers({
      'show:signup': API.showSignup,
      'show:login': API.showLogin,
      'show:forgot:password': API.showForgotPassword
    })
  }
}

const showAuth = (name, label, View) => function (options) {
  if (!navigator.cookieEnabled) {
    return app.execute('show:error:cookieRequired', `show:${name}`)
  }

  if (app.user.loggedIn) { return app.execute('show:home') }

  app.layout.main.show(new View(options))
  return app.navigate(name, { metadata: { title: _.I18n(label) } })
}

// beware that app.layout is undefined when User.define is fired
// app.layout should thus appear only in callbacks
var API = {
  showSignup: showAuth('signup', 'sign up', SignupClassic),

  showLogin: showAuth('login', 'login', Login),

  showForgotPassword (options) {
    app.layout.main.show(new ForgotPassword(options))
    return app.navigate('login/forgot-password',
      { metadata: { title: _.I18n('forgot password') } })
  },

  showResetPassword () {
    if (app.user.loggedIn) {
      app.layout.main.show(new ResetPassword())
      return app.navigate('login/reset-password',
        { metadata: { title: _.I18n('reset password') } })
    } else {
      return app.execute('show:forgot:password')
    }
  },

  logout () { return app.execute('logout') }
}
