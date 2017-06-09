EditorCommons = require './editor_commons'
createEntities = require 'modules/entities/lib/create_entities'

module.exports = EditorCommons.extend
  mainClassName: 'entity-value-editor'
  template: require './templates/entity_value_editor'
  behaviors:
    AlertBox: {}
    AutoComplete: {}
    Tooltip: {}
    PreventDefault: {}

  ui:
    autocomplete: 'input'
    save: '.save'

  initialize: ->
    @property = @model.get 'property'
    @allowEntityCreation = @model.get 'allowEntityCreation'
    @initEditModeState()
    @lazyRender = _.LazyRender @

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
      unless data.claims['wdt:P18']? then delete data.image
      return data

  onShow: ->
    @listenTo @model, 'grab', @onGrab.bind(@)
    @listenTo @model, 'change:value', @lazyRender
    @listenTo app.vent, 'entity:value:editor:edit', @preventMultiEdit.bind(@)

    if @editMode
      @triggerEditEvent()
      @ui.autocomplete.focus()

  onGrab: ->
    if @model.valueEntity?
      @listenToOnce @model.valueEntity, 'change:image', @lazyRenderIfDisplayMode.bind(@)
      # init suggestion with the current value entity so that
      # saving without any change is equivalent to re-selecting the current value
      @suggestion or= @model.valueEntity

    @lazyRender()

  onRender: ->
    @selectIfInEditMode()
    if @editMode then @updateSaveState()

  events:
    'click .edit, .displayModeData': 'showEditMode'
    'click .cancel': 'hideEditMode'
    'click .save': 'save'
    'click .delete': 'delete'
    'keyup input': 'onKeyup'

  # this is a jQuery select, not an autocomplete one
  select: -> @ui.autocomplete.select()

  onAutoCompleteSelect: (suggestion)->
    @suggestion = suggestion
    @updateSaveState()

  onAutoCompleteUnselect: ->
    @suggestion = null
    @updateSaveState()

  # An event to tell every other value editor of the same property
  # that this view passes in edit mode and thus that other view in edit mode
  # should toggle to display mode
  triggerEditEvent: -> app.vent.trigger 'entity:value:editor:edit', @property, @cid

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
        relationEntity = @options.model.entity
        createEntities.byProperty { @property, textValue, relationEntity }
        .then _.Log('created entity')
        .then (entity)=> @_save entity.get('uri')

  updateSaveState: ->
    unless @allowEntityCreation
      if @suggestion? then @ui.save.removeClass 'disabled'
      else @ui.save.addClass 'disabled'
