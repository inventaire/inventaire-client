behaviorsPlugin = require 'modules/general/plugins/behaviors'
forms_ = require 'modules/general/lib/forms'
groups_ = require '../lib/groups'
error_ = require 'lib/error'
PicturePicker = require 'modules/general/views/behaviors/picture_picker'
groupFormData = require '../lib/group_form_data'

module.exports = Marionette.ItemView.extend
  template: require './templates/group_settings'
  behaviors:
    AlertBox: {}
    ConfirmationModal: {}
    ElasticTextarea: {}
    PreventDefault: {}
    SuccessCheck: {}
    BackupForm: {}
    Toggler: {}

  initialize: ->
    @lazyRender = _.LazyRender @, 500

  serializeData: ->
    attrs = @model.serializeData()
    _.extend attrs,
      editName: @editNameData attrs.name
      editDescription: groupFormData.description attrs.description
      userCanLeave: @model.userCanLeave()
      userIsLastUser: @model.userIsLastUser()
      searchability: groupFormData.searchability attrs.searchable

  editNameData: (groupName)->
    nameBase: 'editName'
    field:
      value: groupName
      placeholder: groupName
    button:
      text: _.I18n 'save'
    check: true

  ui:
    editNameField: '#editNameField'
    description: '#description'
    saveCancel: '.saveCancel'
    searchabilityWarning: '.searchability .warning'

  events:
    'click #editNameButton': 'editName'
    'click a#changePicture': 'changePicture'
    'change #searchabilityToggler': 'toggleSearchability'
    'keyup #description': 'showSaveCancel'
    'click .cancelButton': 'cancelDescription'
    'click .saveButton': 'saveDescription'
    'click a.leave': 'leaveGroup'
    'click a.destroy': 'destroyGroup'
    'click #showPositionPicker': 'showPositionPicker'

  onShow: ->
    @listenTo @model, 'change:picture', @lazyRender
    # using lazyRender to let the toggler animation the time to play
    @listenTo @model, 'change:searchable', @lazyRender
    # re-render after a position was selected to display
    # the new geolocation status
    @listenTo @model, 'change:position', @lazyRender
    # re-render to unlock the possibility to leave the group
    # if a new admin was selected
    @listenTo @model, 'list:change:after', @lazyRender

  editName:->
    name = @ui.editNameField.val()
    if name?
      _.preq.start
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

    @updateSettings
      attribute: 'picture'
      value: picture
      selector: '#changePicture'

  toggleSearchability: (e)->
    { checked } = e.currentTarget
    @ui.searchabilityWarning.slideToggle()
    @updateSettings
      attribute: 'searchable'
      value: checked

  updateSettings: (update)->
    update.model = @model
    app.request 'group:update:settings', update

  showSaveCancel: ->
    @_saveCancelShown = false
    unless @_saveCancelShown
      @ui.saveCancel.slideDown()
      @_saveCancelShown = true

  cancelDescription: ->
    @_saveCancelShown = false
    @render()

  saveDescription: ->
    @ui.saveCancel.slideUp()
    @_saveCancelShown = false
    description = @ui.description.val()
    if description?
      _.preq.start
      .then groups_.validateDescription.bind(@, description, '#description')
      .then _.Full(@_updateGroup, @, 'description', description, '#description')
      .catch forms_.catchAlert.bind(null, @)

  leaveGroup: ->
    action = @model.leave.bind @model
    @_leaveGroup 'leave_group_confirmation', 'leave_group_warning', action

  destroyGroup: ->
    group = @model
    action = ->
      group.leave()
      .then ->
        # Dereference group model
        app.user.groups.remove group
        # And change page as staying on the same page would just display
        # the group as empty but accepting a join request
        app.execute 'show:group:user'
      .catch _.ErrorRethrow('destroyGroup action err')

    @_leaveGroup 'destroy_group_confirmation', 'cant_undo_warning', action

  _leaveGroup: (confirmationText, warningText, action)->
    group = @model
    args = { groupName: group.get('name') }

    @$el.trigger 'askConfirmation',
      confirmationText: _.i18n confirmationText, args
      warningText: _.i18n warningText
      action: action
      selector: '#usernameGroup'

  showPositionPicker: ->
    app.execute 'show:position:picker:group', @model
