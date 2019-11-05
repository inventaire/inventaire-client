behaviorsPlugin = require 'modules/general/plugins/behaviors'
forms_ = require 'modules/general/lib/forms'
groups_ = require '../lib/groups'
error_ = require 'lib/error'
PicturePicker = require 'modules/general/views/behaviors/picture_picker'
groupFormData = require '../lib/group_form_data'
getActionKey = require 'lib/get_action_key'
{ ui:groupUrlUi, events:groupUrlEvents, LazyUpdateUrl } = require '../lib/group_url'

module.exports = Marionette.ItemView.extend
  template: require './templates/group_settings'
  behaviors:
    AlertBox: {}
    ElasticTextarea: {}
    PreventDefault: {}
    SuccessCheck: {}
    BackupForm: {}
    Toggler: {}

  initialize: ->
    @lazyRender = _.LazyRender @, 200, true
    @_lazyUpdateUrl = LazyUpdateUrl @

  # Allows to define @_lazyUpdateUrl after events binding
  lazyUpdateUrl: -> @_lazyUpdateUrl()

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
      classes: 'groupNameField'
    button:
      text: _.I18n 'save'
    check: true

  ui: _.extend {}, groupUrlUi,
    editNameField: '#editNameField'
    description: '#description'
    saveCancel: '.saveCancel'
    searchabilityWarning: '.searchability .warning'

  events: _.extend {}, groupUrlEvents,
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
    @listenTo @model, 'change:picture', @LazyRenderFocus('#changePicture')
    # re-render after a position was selected to display
    # the new geolocation status
    @listenTo @model, 'change:position', @LazyRenderFocus('#showPositionPicker')
    # re-render to unlock the possibility to leave the group
    # if a new admin was selected
    @listenTo @model, 'list:change:after', @lazyRender
    # Prevent having to listen for 'change:searchable' among others
    # aas it will be out-of-date only in case of a rollback
    @listenTo @model, 'rollback', @lazyRender

  editName:->
    name = @ui.editNameField.val()
    if name?
      Promise.try groups_.validateName.bind(@, name, '#editNameField')
      .then => @_updateGroup 'name', name, '#editNameField'
      .catch forms_.catchAlert.bind(null, @)

  _updateGroup: (attribute, value, selector)->
    app.request 'group:update:settings', { @model, attribute, value, selector }

  changePicture: ->
    app.layout.modal.show new PicturePicker
      pictures: @model.get 'picture'
      save: @_savePicture.bind(@)
      limit: 1
      focus: '#changePicture'

  _savePicture: (pictures)->
    picture = pictures[0]
    _.log picture, 'picture'
    unless _.isUserImg picture
      message = 'couldnt save picture: requires a local user image url'
      throw error_.new message, pictures

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

  showSaveCancel: (e)->
    specialKey = getActionKey e
    unless specialKey or @_saveCancelShown
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
      Promise.try groups_.validateDescription.bind(@, description, '#description')
      .then => @_updateGroup 'description', description, '#description'
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
        app.groups.remove group
        # And change page as staying on the same page would just display
        # the group as empty but accepting a join request
        app.execute 'show:group:user'
      .catch _.ErrorRethrow('destroyGroup action err')

    @_leaveGroup 'destroy_group_confirmation', 'cant_undo_warning', action

  _leaveGroup: (confirmationText, warningText, action)->
    group = @model
    args = { groupName: group.get('name') }

    app.execute 'ask:confirmation',
      confirmationText: _.i18n confirmationText, args
      warningText: _.i18n warningText
      action: action
      # re-focus on the only existing anchor
      focus: '#groupControls a'

  showPositionPicker: ->
    app.execute 'show:position:picker:group', @model, '#showPositionPicker'
