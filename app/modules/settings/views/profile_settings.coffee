username_ = require 'modules/user/lib/username_tests'
forms_ = require 'modules/general/lib/forms'

module.exports = class ProfileSettings extends Backbone.Marionette.ItemView
  template: require './templates/profile_settings'
  className: 'profileSettings'
  behaviors:
    AlertBox: {}
    SuccessCheck: {}
    ConfirmationModal: {}

  ui:
    username: '#usernameField'
    languagePicker: '#languagePicker'

  initialize: ->
    @listenTo @model, 'change:picture', @render
    @listenTo app.vent, 'i18n:reset', ->
      @render()
      # can't be triggered the 'normal' way as the page is
      # re-rendered when the promise is fulfilled
      @ui.languagePicker.trigger 'check'

  onShow: -> app.execute 'foundation:reload'

  serializeData: ->
    attrs =
      usernamePicker: @usernamePickerData()
      languages: _.deepClone Lang
      changePicture:
        classes: 'max-large-profilePic'
    currentLanguages = app.user.get('language')
    attrs.languages[currentLanguages]?.selected = true
    _.extend attrs, @model.toJSON()
    return attrs

  usernamePickerData: ->
    nameBase: 'username'
    special: true
    field:
      value: @model.get 'username'
    button:
      text: _.i18n 'change username'
      classes: 'dark-grey postfix'

  events:
    'click a#usernameButton': 'verifyUsername'
    'change select#languagePicker': 'changeLanguage'
    'click a#changePicture': 'changePicture'

  verifyUsername: ->
    username = @ui.username.val()
    _.preq.start()
    .then @testUsername.bind(@, username)
    .then username_.verifyUsername.bind(null, username, '#usernameField')
    .then @sendUsernameRequest.bind(@, username)
    .catch forms_.catchAlert.bind(null, @)

  testUsername: (username)->
    if username is app.user.get 'username'
      err = new Error("that's already your username")
      err.selector = '#usernameField'
      throw err
    else
      username_.pass username, '#usernameField'
    return username

  sendUsernameRequest: (username)->
    _.preq.post app.API.auth.username, {username: username}
    .then (res)-> res.username
    .then @confirmUsernameChange.bind(@)

  confirmUsernameChange: (username)->
    @askConfirmation
      requestedUsername: username
      currentUsername: app.user.get 'username'
      model: @model

  askConfirmation: (args)->
    @$el.trigger 'askConfirmation',
      confirmationText: _.i18n('username_change_confirmation', args)
      warningText: _.i18n('username_change_warning')
      actionCallback: updateUser.bind(null, args.requestedUsername)
      actionArgs: args

  changeLanguage: (e)->
    lang = e.target.value
    if lang isnt app.user.get 'language'
      app.request 'user:update',
        attribute:'language'
        value: e.target.value
        selector: '#languagePicker'

  changePicture: ->
    picturePicker = new app.View.Behaviors.PicturePicker
      pictures: @model.get('picture')
      limit: 1
      save: savePicture
    app.layout.modal.show picturePicker

savePicture = (pictures)->
  picture = pictures[0]
  unless _.isUrl picture
    throw new Error 'couldnt save picture: requires a url'

  app.request 'user:update',
    attribute: 'picture'
    value: picture
    selector: '#changePicture'


updateUser = (username)->
  app.request 'user:update',
    attribute: 'username'
    value: username
    selector: '#usernameField'
