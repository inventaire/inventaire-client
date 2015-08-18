MainUser = require './models/main_user'
Signup = require './views/signup'
SignupPersona = require './views/signup_persona'
Login = require './views/login'
LoginPersona = require './views/login_persona'
ForgotPassword = require './views/forgot_password'
ResetPassword = require './views/reset_password'

module.exports =
  define: (module, app, Backbone, Marionette, $, _) ->
    UserRouter = Marionette.AppRouter.extend
      appRoutes:
        'signup(/)':'showSignup'
        'signup/persona(/)':'showSignupPersona'
        'login(/)':'showLogin'
        # this is the route that triggers Persona Signup
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
    unless redirectHomeIfLoggedIn()
      app.layout.main.Show new Signup, _.I18n('sign up')
      app.navigate 'signup'

  showSignupPersona: ->
    unless redirectHomeIfLoggedIn()
      # in standalone mode when not displayed as a region
      # of Signup LayoutView. 'standalone' serves then as boolean
      # for handlebars template to display missing elements
      title = _.I18n('persona sign up')
      app.layout.main.Show new SignupPersona({standalone: true}), title
      app.navigate 'signup/persona'

  showLogin: ->
    unless redirectHomeIfLoggedIn()
      app.layout.main.Show new Login, _.I18n('login')
      app.navigate 'login'

  showLoginPersona: ->
    unless redirectHomeIfLoggedIn()
      # required to navigate before showing
      # as Persona email links redirection depend on the url
      # at the moment the login is triggered
      app.navigate 'login/persona'
      app.layout.main.Show new LoginPersona, _.I18n('persona login')

  showForgotPassword: ->
    app.layout.main.Show new ForgotPassword, _.I18n('forgot password')
    app.navigate 'login/forgot-password'

  showResetPassword: ->
    if app.user.loggedIn
      app.layout.main.Show new ResetPassword, _.I18n('reset password')
    else
      app.execute 'show:forgot:password'


redirectHomeIfLoggedIn = ->
  if app.user.loggedIn
    app.execute 'show:home'
    return true
  else return false

initCommands = (app)->
  app.commands.setHandlers
    'show:signup': API.showSignup
    'show:signup:persona': API.showSignupPersona
    'show:login': API.showLogin
    'show:login:persona': API.showLoginPersona
    'show:forgot:password': API.showForgotPassword

initSubModules = (app)->
  [
    'auth'
    'persona'
    'recover_user_data'
    'user_listings'
    'user_update'
    'user_menu_update'
    'user_language_update'
  ]
  .forEach (name)-> require("./lib/#{name}")(app)
