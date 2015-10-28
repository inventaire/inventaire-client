behaviorsPlugin = require 'modules/general/plugins/behaviors'
forms_ = require 'modules/general/lib/forms'
groups_ = require '../lib/groups'
error_ = require 'lib/error'
PicturePicker = require 'modules/general/views/behaviors/picture_picker'

module.exports = Marionette.ItemView.extend
  template: require './templates/group_settings'
  behaviors:
    AlertBox: {}
    ConfirmationModal: {}
    ElasticTextarea: {}
    PreventDefault: {}
    SuccessCheck: {}

  serializeData: ->
    attrs = @model.serializeData()
    _.extend attrs,
      editName: @editNameData attrs.name
      editDescription: @editDescriptionData attrs.description
      userCanLeave: @model.userCanLeave()
      userIsLastUser: @model.userIsLastUser()

  editNameData: (groupName)->
    nameBase: 'editName'
    field:
      value: groupName
      placeholder: groupName
    button:
      text: _.I18n 'save'
    check: true

  editDescriptionData: (description)->
    id: 'description'
    placeholder: 'enter a group description'
    value: description

  ui:
    editNameField: '#editNameField'
    description: '#description'
    saveCancel: '.saveCancel'

  events:
    'click #editNameButton': 'editName'
    'click a#changePicture': 'changePicture'
    'keyup #description': 'showSaveCancel'
    'click .cancelButton': 'cancelDescription'
    'click .saveButton': 'saveDescription'
    'click a.leave': 'leaveGroup'
    'click a.destroy': 'destroyGroup'

  onShow: ->
    @listenTo @model, 'change:picture', @render.bind(@)

  editName:->
    name = @ui.editNameField.val()
    if name?
      _.preq.start()
      .then groups_.validateName.bind(@, name, '#editNameField')
      .then _.Full(@_updateGroup, @, 'name', name, '#editNameField')
      .catch forms_.catchAlert.bind(null, @)

  _updateGroup: (attribute, value, selector)->
    app.request 'group:update:settings',
      model: @model
      attribute: attribute
      value: value
      selector: selector

  changePicture: ->
    app.layout.modal.show new PicturePicker
      pictures: @model.get 'picture'
      save: @_savePicture.bind(@)
      limit: 1

  _savePicture: (pictures)->
    picture = pictures[0]
    _.log picture, 'picture'
    unless _.isLocalImg picture
      throw new Error 'couldnt save picture: requires a local image url'

    app.request 'group:update:settings',
      model: @model
      attribute: 'picture'
      value: picture
      selector: '#changePicture'

  showSaveCancel: ->
    @_saveCancelShown = false
    unless @_saveCancelShown
      @ui.saveCancel.slideDown()
      @_saveCancelShown = true

  cancelDescription: ->
    @render()
    @_saveCancelShown = false

  saveDescription: ->
    @ui.saveCancel.slideUp()
    @_saveCancelShown = false
    description = @ui.description.val()
    if description?
      _.preq.start()
      .then groups_.validateDescription.bind(@, description, '#description')
      .then _.Full(@_updateGroup, @, 'description', description, '#description')
      .catch forms_.catchAlert.bind(null, @)

  leaveGroup: -> @_leaveGroup 'leave_group_confirmation', 'leave_group_warning',
  destroyGroup: -> @_leaveGroup 'destroy_group_confirmation', 'cant_undo_warning'
  _leaveGroup: (confirmationText, warningText)->
    group = @model
    args = { groupName: group.get('name') }

    @$el.trigger 'askConfirmation',
      confirmationText: _.i18n confirmationText, args
      warningText: _.i18n warningText
      action: group.leave.bind(group)
      selector: '#usernameGroup'
