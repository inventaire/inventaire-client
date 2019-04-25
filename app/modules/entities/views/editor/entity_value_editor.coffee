ClaimsEditorCommons = require './claims_editor_commons'
createEntities = require 'modules/entities/lib/create_entities'
autocomplete = require 'modules/entities/views/editor/lib/autocomplete'

module.exports = ClaimsEditorCommons.extend
  mainClassName: 'entity-value-editor'
  template: require './templates/entity_value_editor'
  behaviors:
    AlertBox: {}
    Tooltip: {}
    PreventDefault: {}

  ui:
    input: 'input'
    save: '.save'

  regions:
    suggestionsRegion: '.suggestionsContainer'

  initialize: ->
    @property = @model.get 'property'
    @allowEntityCreation = @model.get 'allowEntityCreation'
    @initEditModeState()
    @lazyRender = _.LazyRender @
    autocomplete.initialize.call @

  lazyRenderIfDisplayMode: -> if not @editMode then @lazyRender()

  serializeData: ->
    attrs = @model.toJSON()
    attrs.editMode = @editMode
    attrs.valueEntity = @valueEntityData()
    attrs.value = attrs.valueEntity?.label or attrs.value
    if attrs.valueEntity?
      attrs.valueEntity.hasIdentifierTooltipLinks = attrs.valueEntity.type? or attrs.valueEntity.wikidata?
    return attrs

  valueEntityData: ->
    { valueEntity } = @model
    if valueEntity?
      data = valueEntity.toJSON()
      # Do not display an image if it's not the entity's own image
      # (e.g. if it's a work that deduced an image from one of its editions)
      # as it might be confusing
      unless data.claims['invp:P2']? then delete data.image
      return data

  onShow: ->
    @listenTo @model, 'grab', @onGrab.bind(@)
    @listenTo @model, 'change:value', @lazyRender
    @listenTo app.vent, 'entity:value:editor:edit', @preventMultiEdit.bind(@)

    if @editMode
      @triggerEditEvent()
      @ui.input.focus()

  onGrab: ->
    if @model.valueEntity?
      @listenToOnce @model.valueEntity, 'change:image', @lazyRenderIfDisplayMode.bind(@)
      # init suggestion with the current value entity so that
      # saving without any change is equivalent to re-selecting the current value
      @suggestion or= @model.valueEntity

    @lazyRender()

  onRender: ->
    @selectIfInEditMode()
    if @editMode
      @updateSaveState()
      autocomplete.onRender.call @

  events:
    'click .edit, .displayModeData': 'showEditMode'
    'click .cancel': 'hideEditMode'
    'click .save': 'save'
    'click .delete': 'delete'
    'click .close': 'hideDropdown'
    'keyup input': 'onKeyUp'

  onKeyUp: (e)->
    ClaimsEditorCommons::onKeyUp.call @, e
    if @editMode then autocomplete.onKeyUp.call @, e

  onKeyDown: (e)->
    if @editMode then autocomplete.onKeyDown.call @, e

  hideDropdown: autocomplete.hideDropdown

  # this is a jQuery select, not an autocomplete one
  select: -> @ui.input.select()

  onAutoCompleteSelect: (suggestion)->
    @suggestion = suggestion
    @updateSaveState()

  onAutoCompleteUnselect: ->
    @suggestion = null
    @updateSaveState()

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
        textValue = @ui.input.val()
        relationEntity = @options.model.entity
        createEntities.byProperty { @property, textValue, relationEntity }
        .then _.Log('created entity')
        .then (entity)=> @_save entity.get('uri')

  updateSaveState: ->
    unless @allowEntityCreation
      if @suggestion? then @ui.save.removeClass 'disabled'
      else @ui.save.addClass 'disabled'
