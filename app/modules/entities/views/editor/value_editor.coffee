forms_ = require 'modules/general/lib/forms'
error_ = require 'lib/error'
getActionKey = require 'lib/get_action_key'

module.exports = Marionette.ItemView.extend
  className: -> "value-editor #{@cid}"
  template: require './templates/value_editor'
  behaviors:
    AlertBox: {}
    AutoComplete: {}

  ui:
    autocomplete: 'input'

  initialize: ->
    @editMode = false
    @lazyRender = _.LazyRender @, 200

  serializeData: ->
    attr = @model.toJSON()
    { valueEntity } = @model
    attr.label = valueEntity?.get 'label'
    attr.editMode = @editMode
    return attr

  onShow: ->
    @listenTo @model, 'grab', @lazyRender
    @listenTo @model, 'change:value', @lazyRender

  events:
    'click .edit, .label': 'showEditMode'
    'click .cancel': 'hideEditMode'
    'click .save': 'save'
    'keyup input': 'hideEditModeIfEsc'

  showEditMode: ->
    @toggleEditMode true
    # select after toggleEditMode lazyRender re-rendered
    setTimeout @select.bind(@), 150

  select: -> @ui.autocomplete.select()

  hideEditMode: -> @toggleEditMode false

  hideEditModeIfEsc: (e)->
    key = getActionKey e
    if key is 'esc' then @hideEditMode()

  toggleEditMode: (bool)->
    @editMode = bool
    @lazyRender()

  save: ->
    oldValue = @model.get 'value'
    newValue = @ui.autocomplete.attr 'data-autocomplete-value'
    _.log oldValue, 'oldValue'
    _.log newValue, 'newValue'

    _.inspect @, 'value editor'

    if newValue? and newValue isnt oldValue
      property = @model.get 'property'

      # Changing the model value only once saved successfully
      # to avoid re-rendering without confirmation
      # knowing that re-rendering could interfere with the alertBox
      @model.set 'value', newValue
      # Reset the value entity to avoid showing the former entity's label
      # while we wait for the new entity to be grabbed
      prevValueEntity = @model.valueEntity
      @model.valueEntity = null

      reverseAction = =>
        @model.set 'value', oldValue
        @model.valueEntity = prevValueEntity

      rollback = _.Rollback reverseAction, 'value_editor save'


      # Also waiting to hideEditMode as it triggers a (lazy) re-render too
      @hideEditMode()

      @model.entity.savePropertyValue property, oldValue, newValue
      .catch rollback
      # target only this view
      .catch error_.Complete(".#{@cid} .has-alertbox")
      .catch @_catchAlert.bind(@)

    else
      @hideEditMode()

  _catchAlert: (err)->
    alert = =>
      # Making sure that we are in edit mode as it might have re-rendered
      # already before the error came back from the server
      @showEditMode()
      forms_.catchAlert @, err

    # let the time to the changes and rollbacks to trigger lazy re-render
    # before trying to show the alert message
    setTimeout alert, 1000
