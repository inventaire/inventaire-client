SignupClassic = require './views/signup_classic'
Login = require './views/login'
ForgotPassword = require './views/forgot_password'
ResetPassword = require './views/reset_password'
fetchData = require 'lib/data/fetch'

module.exports =
  define: (module, app, Backbone, Marionette, $, _)->
    Router = Marionette.AppRouter.extend
      appRoutes:
        'signup(/)':'showSignup'
        'login(/)':'showLogin'
        'login/forgot-password(/)':'showForgotPassword'
        'login/reset-password(/)':'showResetPassword'

    app.addInitializer -> new Router { controller: API }

    require('./lib/init_main_user')(app)
    require('./lib/auth')(app)
    require('./lib/user_listings')(app)
    require('./lib/user_update')(app)

    app.commands.setHandlers
      'show:signup': API.showSignup
      'show:login': API.showLogin
      'show:forgot:password': API.showForgotPassword

# beware that app.layout is undefined when User.define is fired
# app.layout should thus appear only in callbacks
API =
  showSignup: ->
    unless redirected 'show:signup'
      app.layout.main.show new SignupClassic
      app.navigate 'signup', { metadata: { title: _.I18n('sign up') } }

  showLogin: ->
    unless redirected 'show:login'
      app.layout.main.show new Login
      app.navigate 'login', { metadata: { title: _.I18n('login') } }

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

redirected = (command)->
  unless navigator.cookieEnabled
    app.execute 'show:error:cookieRequired', command
    return true

  unless app.user.loggedIn then return false

  app.execute 'show:home'
  return true
