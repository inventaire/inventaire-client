forms_ = require 'modules/general/lib/forms'
unselectPlugin = require 'modules/inventory/plugins/unselect'
relationsActions = require 'modules/users/plugins/relations_actions'

module.exports = Marionette.ItemView.extend
  template: require './templates/user_profile'
  events:
    'click #editBio': 'editBio'
    'click #saveBio': 'saveBio'
    'click #cancelBio': 'cancelBio'
    'click #editPicture': 'editPicture'
    'click a#changePicture': 'changePicture'

  behaviors:
    AlertBox: {}
    SuccessCheck: {}
    Loading: {}
    ElasticTextarea: {}
    ConfirmationModal: {}

  ui:
    bio: '.bio'
    bioText: 'textarea.bio'

  serializeData: ->
    _.extend @model.serializeData(),
      onUserProfile: true
      loggedIn: app.user.loggedIn

  initialize: ->
    @listenTo @model, 'change', @render.bind(@)
    @initPlugin()

  initPlugin: ->
    unselectPlugin.call @
    relationsActions.call @

  onShow: ->
    @makeRoom()
    @updateBreadCrumb()

    # take care of destroying this view even on events out of this
    # view scope (ex: clicking the home button)
    @listenTo app.vent, 'inventory:change', @destroyOnInventoryChange

  destroyOnInventoryChange: (username)->
    unless username is @model.get('username')
      @$el.slideUp 500, @destroy.bind(@)

  onDestroy: ->
    @giveRoomBack()
    @notifyBreadCrumb()

  makeRoom: -> $('#one').addClass 'notEmpty'
  giveRoomBack: -> $('#one').removeClass 'notEmpty'

  updateBreadCrumb: ->
    app.execute 'current:username:set', @model.get('username')
  notifyBreadCrumb: ->
    app.execute 'current:username:hide'

  editBio: -> @ui.bio.toggle()
  cancelBio: -> @ui.bio.toggle()
  saveBio: ->
    currentBio = @model.get('bio')
    bio = @ui.bioText.val()
    if bio is currentBio then return @cancelBio()

    _.preq.start()
    .then @testBio.bind(null, bio)
    .then @updateUserBio.bind(null, bio)
    .then @ui.bio.toggle.bind(@ui.bio)
    .catch forms_.catchAlert.bind(null, @)

  testBio: (bio)->
    if bio.length > 1000
      formatErr new Error("the bio can't be longer than 1000 characters")

  updateUserBio: (bio)->
    prev = app.user.get 'bio'
    app.user.set 'bio', bio
    app.request 'user:update',
      attribute: 'bio'
      value: bio
      selector: '#usernameButton'
    .catch (err)->
      app.user.set 'bio', prev
      formatErr(err)

  changePicture: require 'modules/user/lib/change_user_picture'

formatErr = (err)->
  err.selector = 'textarea.bio'
  throw err