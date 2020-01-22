username_ = require 'modules/user/lib/username_tests'
forms_ = require 'modules/general/lib/forms'
error_ = require 'lib/error'
behaviorsPlugin = require 'modules/general/plugins/behaviors'
{ testAttribute, pickerData } = require '../lib/helpers'

module.exports = Marionette.ItemView.extend
  template: require './templates/profile_settings'
  className: 'profileSettings'
  behaviors:
    AlertBox: {}
    SuccessCheck: {}
    Loading: {}

  ui:
    username: '#usernameField'
    bioTextarea: '#bio'

  initialize: ->
    _.extend @, behaviorsPlugin
    @listenTo @model, 'change:picture', @render
    @listenTo @model, 'change:position', @render

  serializeData: ->
    attrs = @model.toJSON()
    return _.extend attrs,
      userPathname: app.user.get('pathname')
      usernamePicker: @usernamePickerData()
      changePicture:
        classes: 'max-large-profilePic'
      hasPosition: @model.hasPosition()
      position: @model.getCoords()

  usernamePickerData: -> pickerData @model, 'username'

  languagesData: ->
    languages = _.deepClone activeLanguages
    currentLanguage = _.shortLang @model.get('language')
    languages[currentLanguage]?.selected = true
    return languages

  events:
    'click a#changePicture': 'changePicture'
    'click a#usernameButton': 'updateUsername'
    'click #saveBio': 'saveBio'
    'click #showPositionPicker': -> app.execute 'show:position:picker:main:user'
    'click .done': 'showMainUserInventory'

  # USERNAME
  updateUsername: ->
    username = @ui.username.val()
    Promise.try @testUsername.bind(@, username)
    .then =>
      # if the username update is just a change in case
      # it should be rejected because the username is already taken
      # which it will be given usernames concurrency is case insensitive
      if @usernameCaseChange username then return
      else return username_.verifyUsername username, '#usernameField'
    .then => @confirmUsernameChange username
    .catch forms_.catchAlert.bind(null, @)

  usernameCaseChange: (username)->
    username.toLowerCase() is @model.get('username').toLowerCase()

  testUsername: (username)->
    testAttribute 'username', username, username_

  confirmUsernameChange: (username)->
    action = @updateUserUsername.bind @, username
    @askConfirmation action,
      requestedUsername: username
      currentUsername: app.user.get 'username'
      usernameCaseChange: @usernameCaseChange username
      model: @model

  askConfirmation: (action, args)->
    { usernameCaseChange } = args
    app.execute 'ask:confirmation',
      confirmationText: _.i18n('username_change_confirmation', args)
      # no need to show the warning if it's just a case change
      warningText: unless usernameCaseChange then _.i18n 'username_change_warning'
      action: action
      selector: '#usernameGroup'

  updateUserUsername: (username)->
    app.request 'user:update',
      attribute: 'username'
      value: username
      selector: '#usernameButton'

  # BIO
  saveBio: ->
    bio = @ui.bioTextarea.val()

    Promise.try validateBio.bind(null, bio)
    .then updateUserBio.bind(null, bio)
    .catch error_.Complete('#bio')
    .catch forms_.catchAlert.bind(null, @)

  # PICTURE
  changePicture: require 'modules/user/lib/change_user_picture'

  # DONE
  showMainUserInventory: (e)->
    unless _.isOpenedOutside e then app.execute 'show:inventory:main:user'

validateBio = (bio)->
  if bio.length > 1000
    throw error_.new "the bio can't be longer than 1000 characters", { length: bio.length }

updateUserBio = (bio)->
  app.request 'user:update',
    attribute: 'bio'
    value: bio
    selector: '#bio'
