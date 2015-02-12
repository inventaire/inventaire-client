usernameTests = require 'modules/user/lib/username_tests'

module.exports = class ProfileSettings extends Backbone.Marionette.ItemView
  template: require './templates/profile_settings'
  className: 'profileSettings'
  behaviors:
    AlertBox: {}
    SuccessCheck: {}
    ConfirmationModal: {}

  initialize: ->
    @listenTo @model, 'change:picture', @render
    @listenTo app.vent, 'i18n:reset', ->
      @render()
      # can't be triggered the 'normal' way as the page is
      # re-rendered when the promise is fulfilled
      $('#languagePicker').trigger 'check'

  onShow: -> app.execute 'foundation:reload'

  serializeData: ->
    attrs =
      usernamePicker:
        nameBase: 'username'
        special: true
        field:
          value: @model.get 'username'
        button:
          text: _.i18n 'change username'
          classes: 'dark-grey postfix'
      languages: _.deepClone Lang
      changePicture:
        classes: 'max-large-profilePic'
    currentLanguages = app.user.get('language')
    attrs.languages[currentLanguages]?.selected = true
    _.extend attrs, @model.toJSON()
    return attrs

  events:
    'click a#usernameButton': 'verifyUsername'
    'change select#languagePicker': 'changeLanguage'
    'click a#changePicture': 'changePicture'

  verifyUsername: ->
    requestedUsername = $('#usernameField').val()
    if requestedUsername is app.user.get 'username'
      @invalidUsername "that's already your username"
    else
      usernameTests.validate
        username: requestedUsername
        success: @sendUsernameRequest.bind(@)
        view: @

  sendUsernameRequest: (requestedUsername)->
    $.post app.API.auth.username, {username: requestedUsername}
    .then (res)=> @confirmUsernameChange(res.username)
    .fail @invalidUsername.bind(@)

  invalidUsername: usernameTests.invalidUsername

  confirmUsernameChange: (requestedUsername)=>
    args =
      requestedUsername: requestedUsername
      currentUsername: app.user.get 'username'
      model: @model
    confirmationText = """
    Your current username is <strong>#{args.currentUsername}</strong><br>
    Are you sure you want to change for <strong>#{args.requestedUsername}</strong>?
    """
    warningText = """
    You shouldn't change your username too often, as it's the way others can find you
    """
    @$el.trigger 'askConfirmation',
      confirmationText: _.i18n(confirmationText)
      warningText: _.i18n(warningText)
      actionCallback: (args)=>
        params =
          attribute: 'username'
          value: args.requestedUsername
          selector: '#usernameField'
        return app.request 'user:update', params
      actionArgs: args

  changeLanguage: (e)->
    lang = e.target.value
    if lang isnt app.user.get 'language'
      app.request 'user:update',
        attribute:'language'
        value: e.target.value
        selector: '#languagePicker'

  changePicture: ->
    picturePicker = new app.View.Behaviors.PicturePicker {
      pictures: @model.get('picture')
      limit: 1
      save: (pictures)=>
        picture = pictures[0]
        if _.isUrl picture
          app.request 'user:update',
            attribute: 'picture'
            value: picture
            selector: '#changePicture'
        else
          console.error 'couldnt save picture: requires a url'
    }
    app.layout.modal.show picturePicker
