MainUser = require './models/main_user'
Signup =
  Step1: require './views/signup_step_1'
  Step2: require './views/signup_step_2'
Login =
  Step1: require './views/login_step_1'

module.exports =
  define: (module, app, Backbone, Marionette, $, _) ->
    UserRouter = Marionette.AppRouter.extend
      appRoutes:
        'signup(/1)(/)':'showSignupStep1'
        'signup/2(/)':'showSignupStep2'
        'login(/)':'showLogin'

    app.addInitializer ->
      new UserRouter
        controller: API

    app.user = new MainUser
    initCommands(app)
    initSubModules(app)


# beware that app.layout is undefined when User.define is fired
# app.layout should thus appear only in callbacks
API =
  showSignupStep1: ->
    if app.user.loggedIn then app.execute 'show:home'
    else
      app.layout.main.show new Signup.Step1 {model: app.user}
      app.navigate 'signup'

  showSignupStep2: ->
    app.layout.main.show new Signup.Step2 {model: app.user}
    app.navigate 'signup/2'

  showLogin: ->
    if app.user.loggedIn then app.execute 'show:home'
    else
      app.layout.main.show new Login.Step1 {model: app.user}
      app.navigate 'login'

initCommands = (app)->
  app.commands.setHandlers
    'show:signup': API.showSignupStep1
    'show:signup:step1': API.showSignupStep1
    'show:signup:step2': API.showSignupStep2
    'show:login': API.showLogin
    'show:login:step1': API.showLogin

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
