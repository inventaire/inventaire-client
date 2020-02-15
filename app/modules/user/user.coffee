SignupClassic = require './views/signup_classic'
Login = require './views/login'
ForgotPassword = require './views/forgot_password'
ResetPassword = require './views/reset_password'

module.exports =
  define: (module, app, Backbone, Marionette, $, _)->
    Router = Marionette.AppRouter.extend
      appRoutes:
        'signup(/)': 'showSignup'
        'login(/)': 'showLogin'
        'login/forgot-password(/)': 'showForgotPassword'
        'login/reset-password(/)': 'showResetPassword'
        'logout(/)': 'logout'

    app.addInitializer -> new Router { controller: API }

    require('./lib/init_main_user')(app)
    require('./lib/auth')(app)
    require('./lib/user_listings')(app)
    require('./lib/user_update')(app)

    app.commands.setHandlers
      'show:signup': API.showSignup
      'show:login': API.showLogin
      'show:forgot:password': API.showForgotPassword


showAuth = (name, label, View)-> (options)->
  unless navigator.cookieEnabled
    return app.execute 'show:error:cookieRequired', "show:#{name}"

  if app.user.loggedIn then return app.execute 'show:home'

  app.layout.main.show new View options
  app.navigate name, { metadata: { title: _.I18n(label) } }

# beware that app.layout is undefined when User.define is fired
# app.layout should thus appear only in callbacks
API =
  showSignup: showAuth 'signup', 'sign up', SignupClassic

  showLogin: showAuth 'login', 'login', Login

  showForgotPassword: (options)->
    app.layout.main.show new ForgotPassword options
    app.navigate 'login/forgot-password',
      metadata: { title: _.I18n('forgot password') }

  showResetPassword: ->
    if app.user.loggedIn
      app.layout.main.show new ResetPassword
      app.navigate 'login/reset-password',
        metadata: { title: _.I18n('reset password') }
    else
      app.execute 'show:forgot:password'

  logout: -> app.execute 'logout'
