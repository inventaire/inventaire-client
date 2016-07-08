forms_ = require 'modules/general/lib/forms'
error_ = require 'lib/error'
getActionKey = require 'lib/get_action_key'
isLoggedIn = require './lib/is_logged_in'
createEntities = require 'modules/entities/lib/create_entities'

module.exports = Marionette.ItemView.extend
  className: -> "value-editor #{@cid}"
  template: require './templates/value_editor'
  behaviors:
    AlertBox: {}
    AutoComplete: {}
    ConfirmationModal: {}

  ui:
    autocomplete: 'input'
    save: '.save'

  initialize: ->
    @property = @model.get 'property'
    @allowEntityCreation = @model.get 'allowEntityCreation'
    # If the model's value is null, start in edit mode
    @editMode = if @model.get('value')? then false else true
    @lazyRender = _.LazyRender @, 200

  lazyRenderIfDisplayMode: -> if not @editMode then @lazyRender()

  serializeData: ->
    attr = @model.toJSON()
    attr.valueEntity = @valueEntityData()
    attr.text = attr.valueEntity?.label or attr.value
    attr.editMode = @editMode
    return attr

  valueEntityData: ->
    { valueEntity } = @model
    if valueEntity? then valueEntity.toJSON()

  onShow: ->
    @listenTo @model, 'grab', @onGrab.bind(@)
    @listenTo @model, 'change:value', @lazyRender
    @listenTo app.vent, 'entity:value:editor:edit', @preventMultiEdit.bind(@)

    if @editMode then @triggerEditEvent()

  onGrab: ->
    if @model.valueEntity?
      @listenToOnce @model.valueEntity, 'change:pictures', @lazyRenderIfDisplayMode.bind(@)
      # init suggestion with the current value entity so that
      # saving without any change is equivalent to re-selecting the current value
      @suggestion or= @model.valueEntity

    @lazyRender()

  onRender: ->
    if @editMode
      # somehow seems to need a delay
      setTimeout @select.bind(@), 100

      @updateSaveState()

  events:
    'click .edit, .data': 'showEditMode'
    'click .cancel': 'hideEditMode'
    'click .save': 'save'
    'click .delete': 'delete'
    'keyup input': 'hideEditModeIfEsc'

  showEditMode: (e)->
    if isLoggedIn()
      # Clicking on the identifier should only open wikidata in another window
      if e?.target.className is 'identifier' then return

      @toggleEditMode true
      @triggerEditEvent()

  # this is a jQuery select, not an autocomplete one
  select: -> @ui.autocomplete.select()

  onAutoCompleteSelect: (suggestion)->
    @suggestion = suggestion
    @updateSaveState()

  onAutoCompleteUnselect: ->
    @suggestion = null
    @updateSaveState()

  hideEditMode: ->
    @toggleEditMode false
    # In case an empty value was created to allow creating a new claim
    # but the action was cancelled
    if not @model.get('value')? then @model.destroy()

  hideEditModeIfEsc: (e)->
    key = getActionKey e
    switch key
      when 'esc' then @hideEditMode()
      when 'enter'
        if e.ctrlKey then @save()

  toggleEditMode: (bool)->
    @editMode = bool
    @lazyRender()

  # An event to tell every other value editor of the same property
  # that this view passes in edit mode and thus that other view in edit mode
  # should toggle to display mode
  triggerEditEvent: ->
    app.vent.trigger 'entity:value:editor:edit', @property, @cid
  preventMultiEdit: (property, viewCid)->
    if @editMode and property is @property and @cid isnt viewCid
      @hideEditMode()

  # TODO: prevent an existing entity to be re created just
  # because we passed in edit mode and clicked save
  save: ->
    uri = @suggestion?.get 'uri'
    # if the suggestion is the same as the current value, ignore
    if uri is @model.get('value') then return @hideEditMode()

    if @suggestion? then return @_save uri
    else
      if @allowEntityCreation
        textValue = @ui.autocomplete.val()
        createEntities.byProperty
          property: @property
          textValue: textValue
        .then _.Log('created entity')
        .then (entity)=> @_save entity.get('uri')

  _save: (newValue)->
    @model.saveValue newValue
    # target only this view
    .catch error_.Complete(".#{@cid} .has-alertbox")
    .catch @_catchAlert.bind(@)

    @hideEditMode()

  _catchAlert: (err)->
    # Making sure that we are in edit mode as it might have re-rendered
    # already before the error came back from the server
    @showEditMode()

    alert = => forms_.catchAlert @, err
    # Let the time to the changes and rollbacks to trigger lazy re-render
    # before trying to show the alert message
    setTimeout alert, 500

  delete: ->
    action = => @_save null

    @$el.trigger 'askConfirmation',
      confirmationText: _.i18n 'Are you sure you want to delete this statement?'
      action: action

  updateSaveState: ->
    unless @allowEntityCreation
      if @suggestion? then @ui.save.removeClass 'disabled'
      else @ui.save.addClass 'disabled'
