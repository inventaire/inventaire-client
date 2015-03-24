MainUser = require './models/main_user'
Signup = require './views/signup'
SignupPersona = require './views/signup_persona'
Login = require './views/login'
LoginPersona = require './views/login_persona'
ForgotPassword = require './views/forgot_password'

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
      app.layout.main.show new Signup
      app.navigate 'signup'

  showSignupPersona: ->
    unless redirectHomeIfLoggedIn()
      # in standalone mode when not displayed as a region
      # of Signup LayoutView. 'standalone' serves then as boolean
      # for handlebars template to display missing elements
      app.layout.main.show new SignupPersona {standalone: true}
      app.navigate 'signup/persona'

  showLogin: ->
    unless redirectHomeIfLoggedIn()
      app.layout.main.show new Login
      app.navigate 'login'

  showLoginPersona: ->
    unless redirectHomeIfLoggedIn()
      # required to navigate before showing
      # as Persona email links redirection depend on the url
      # at the moment the login is triggered
      app.navigate 'login/persona'
      app.layout.main.show new LoginPersona

  showForgotPassword: ->
    app.layout.main.show new ForgotPassword
    app.navigate 'login/forgot-password'

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
