module.exports =
  define: (module, app, Backbone, Marionette, $, _) ->
    UserRouter = Marionette.AppRouter.extend
      appRoutes:
        'signup':'showSignupStep1'
        # 'signup/1':'showSignupStep1'
        # 'signup/2':'showSignupStep2'
        'login':'showLogin'

    app.addInitializer ->
      new UserRouter
        controller: API

    initializePersona(app)
    app.user = new app.Model.User
    recoverUserData(app)
    initializeUserI18nSettings(app)
    initializeUserEditionCommands(app)
    initializeUserMenuUpdate(app)
    initializeSignupLoginHandlers(app)
    initializeUserListings(app)

# beware that app.layout is undefined when User.define is fired
# app.layout should thus appear only in callbacks
API =
  showSignupStep1: ->
    app.layout.main.show new app.View.Signup.Step1 {model: app.user}
    app.navigate 'signup'
  showSignupStep2: ->
    app.layout.main.show new app.View.Signup.Step2 {model: app.user}
    # app.navigate 'signup/2'
  showLogin: ->
    app.layout.main.show new app.View.Login.Step1 {model: app.user}
    app.navigate 'login'


initializeSignupLoginHandlers = (app)->
  app.commands.setHandlers
    'show:signup': API.showSignupStep1
    'show:signup:step1': API.showSignupStep1
    'show:signup:step2': API.showSignupStep2
    'show:login': API.showLogin
    'show:login:step1': API.showLogin


initializePersona = (app)->
  if navigator.id?
    navigator.id.logout()
    navigator.id.watch
      onlogin: onlogin
      onlogout: onlogout
  else unreachablePersona()

  app.commands.setHandlers
    'persona:login': ->
      if navigator.id? then navigator.id.request()
      else unreachablePersona()
    'persona:logout': ->
      $.post(app.API.auth.logout)
      .then (data)->
        window.location.reload()
        _.log "You have been successfully logged out"

unreachablePersona = ->
  throw new Error 'Persona Login not available: you might be offline'

onlogin = (assertion) ->
  input =
    assertion: assertion
    username: app.user.get('username')
    _csrf: $('#token').val()
  $.post(app.API.auth.login, input)
  .then (data)->
    if typeof data is 'object'
      # will get user data on reload's fetch
      window.location.reload()
    else console.error 'onlogin: invalid data'
  .fail (err)->
    app.vent.trigger 'persona:error', err
    throw new Error JSON.stringify(err)

onlogout = ->
  app.vent.trigger 'debug', arguments, 'fake logout: avoid login loop'


recoverUserData = (app)->
  if $.cookie('email')?
    app.user.fetch()
    .then (userAttrs)->
      unless app.user.get('language')?
        if lang = $.cookie 'lang'
          _.log app.user.set('language', lang), 'language set from cookie'
    .fail (err)->
      _.log err, 'app.user.fetch fail'
      throw new Error err
    .done()
    app.user.loggedIn = true
  else
    app.user.loggedIn = false

initializeUserI18nSettings = (app)->
  app.user.on 'change:language', (data)->
    if (lang = app.user.get('language')) isnt app.polyglot.currentLocale
      _.log lang, 'i18n: user data change: i18n change requested'
      app.request 'i18n:set', lang
      _.setCookie 'lang', lang


initializeUserEditionCommands = (app)->
  app.reqres.setHandlers
    'user:update': (options)->
      app.user.set options.fieldName, options.value
      return app.user.save()

initializeUserMenuUpdate = (app)->
  app.commands.setHandlers
    'show:user:menu:update': ->
      if app.user.has 'email'
        app.layout?.accountMenu.show new app.View.AccountMenu {model: app.user}
      else app.layout?.accountMenu.show new app.View.NotLoggedMenu

  app.user.on 'change', (user)-> app.execute 'show:user:menu:update'


initializeUserListings = (app)->
  app.user.listings =
    private:
      id: 'private'
      icon: 'lock'
      unicodeIcon: '&#xf023;'
      label: 'Private Inventory'
    contacts:
      id: 'contacts'
      icon: 'users'
      unicodeIcon: '&#xf0c0;'
      label: 'Shared Inventory'
    public:
      id: 'public'
      icon: 'globe'
      unicodeIcon: '&#xf0ac;'
      label: 'Public Inventory'