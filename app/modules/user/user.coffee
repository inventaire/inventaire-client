MainUser = require './models/main_user'
SignupClassic = require './views/signup_classic'
Login = require './views/login'
LoginPersona = require './views/login_persona'
ForgotPassword = require './views/forgot_password'
ResetPassword = require './views/reset_password'

module.exports =
  define: (module, app, Backbone, Marionette, $, _) ->
    UserRouter = Marionette.AppRouter.extend
      appRoutes:
        'signup(/persona)(/)':'showSignup'
        'login(/)':'showLogin'
        # this is the route that was triggered by Persona Signup
        # so that Persona confirmation email returns to this route
        'login/persona(/)':'showLoginPersona'
        'login/forgot-password(/)':'showForgotPassword'
        'login/reset-password(/)':'showResetPassword'

    app.addInitializer ->
      new UserRouter
        controller: API

    app.user = new MainUser
    initCommands(app)
    initSubModules(app)


# beware that app.layout is undefined when User.define is fired
# app.layout should thus appear only in callbacks
API =

  showSignup: ->
    unless redirected 'show:signup'
      app.layout.main.Show new SignupClassic, _.I18n('sign up')
      app.navigate 'signup'

  showLogin: ->
    unless redirected 'show:login'
      app.layout.main.Show new Login, _.I18n('login')
      app.navigate 'login'

  showLoginPersona: ->
    unless redirected 'show:login:persona'
      # required to navigate before showing
      # as Persona email links redirection depend on the url
      # at the moment the login is triggered
      app.navigate 'login/persona'
      app.layout.main.Show new LoginPersona, _.I18n('login with Persona')

  showForgotPassword: (options)->
    app.layout.main.Show new ForgotPassword(options), _.I18n('forgot password')
    app.navigate 'login/forgot-password'

  showResetPassword: ->
    if app.user.loggedIn
      app.layout.main.Show new ResetPassword, _.I18n('reset password')
    else
      app.execute 'show:forgot:password'


redirected = (command)->
  unless navigator.cookieEnabled
    app.execute 'show:error:cookieRequired', command
    return true

  unless app.user.loggedIn then return false

  app.execute 'show:home'
  return true

initCommands = (app)->
  app.commands.setHandlers
    'show:signup': API.showSignup
    'show:login': API.showLogin
    'show:login:persona': API.showLoginPersona
    'show:forgot:password': API.showForgotPassword

subModules = [
    'auth'
    'recover_user_data'
    'user_listings'
    'user_update'
    'user_menu_update'
    'user_language_update'
  ]

initSubModules = (app)->
  for subModule in subModules
    require("./lib/#{subModule}")(app)
