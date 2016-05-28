forms_ = require 'modules/general/lib/forms'
error_ = require 'lib/error'
getActionKey = require 'lib/get_action_key'
isLoggedIn = require './lib/is_logged_in'

module.exports = Marionette.ItemView.extend
  className: -> "value-editor #{@cid}"
  template: require './templates/value_editor'
  behaviors:
    AlertBox: {}
    AutoComplete: {}

  ui:
    autocomplete: 'input'

  initialize: ->
    # If the model's value is null, start in edit mode
    @editMode = if @model.get('value')? then false else true
    @lazyRender = _.LazyRender @, 200

  serializeData: ->
    attr = @model.toJSON()
    attr.valueEntity = @valueEntityData()
    attr.editMode = @editMode
    return attr

  valueEntityData: ->
    { valueEntity } = @model
    if valueEntity? then valueEntity.toJSON()

  onShow: ->
    @listenTo @model, 'grab', @lazyRender
    @listenTo @model, 'change:value', @lazyRender

  onRender: ->
    # Empty values should be allowed only in editMode
    # (to allow adding a new value)
    # non editMode should clear the value model
    # Known case: after a value rollback
    if not @editMode and not @model.get('value')?
      @model.destroy()

  events:
    'click .edit, .data': 'showEditMode'
    'click .cancel': 'hideEditMode'
    'click .save': 'save'
    'keyup input': 'hideEditModeIfEsc'

  showEditMode: (e)->
    if isLoggedIn()
      # Clicking on the identifier should only open wikidata in another window
      if e?.target.className is 'identifier' then return

      @toggleEditMode true
      # select after toggleEditMode lazyRender re-rendered
      setTimeout @select.bind(@), 150

  select: -> @ui.autocomplete.focus().select()

  hideEditMode: -> @toggleEditMode false

  hideEditModeIfEsc: (e)->
    key = getActionKey e
    switch key
      when 'esc' then @hideEditMode()
      when 'enter'
        if e.ctrlKey then @save()

  toggleEditMode: (bool)->
    @editMode = bool
    @lazyRender()

  save: ->
    oldValue = @model.get 'value'
    oldValueEntity = @model.valueEntity
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
      @model.valueEntity = null

      reverseAction = =>
        @model.set 'value', oldValue
        @model.valueEntity = oldValueEntity

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
    # Making sure that we are in edit mode as it might have re-rendered
    # already before the error came back from the server
    @showEditMode()

    alert = => forms_.catchAlert @, err
    # Let the time to the changes and rollbacks to trigger lazy re-render
    # before trying to show the alert message
    setTimeout alert, 500
