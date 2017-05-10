TitleEditor = require './title_editor'
PropertiesEditor = require './properties_editor'
propertiesCollection = require 'modules/entities/lib/editor/properties_collection'
AdminSection = require './admin_section'
forms_ = require 'modules/general/lib/forms'
error_ = require 'lib/error'
entityDraftModel = require 'modules/entities/lib/entity_draft_model'

module.exports = Marionette.LayoutView.extend
  id: 'entityEdit'
  template: require './templates/entity_edit'
  behaviors:
    PreventDefault: {}
    AlertBox: {}

  regions:
    title: '.title'
    claims: '.claims'
    admin: '.admin'

  ui:
    navigationButtons: '.navigationButtons'

  initialize: ->
    @userIsAdmin = app.user.get 'admin'
    @creationMode = @model.creating
    @requiresLabel = @model.type isnt 'edition'
    @showAdminSection = @userIsAdmin and not @creationMode

    { waitForSubentities } = @model
    # Some entity type don't automatically fetch their subentities
    # even for the editor, as sub entites are displayed on the entities' page
    # already
    waitForSubentities or= _.preq.resolved

    @waitForPropCollection = waitForSubentities
      .then @initPropertiesCollections.bind(@)

    @navigationButtonsDisabled = false

    { @next, @relation } = @options
    @multiEdit = @next? or @relation?
    if @relation?
      @previousData = @model.get('claims')[@relation]

  initPropertiesCollections: -> @properties = propertiesCollection @model

  onShow: ->
    if @requiresLabel
      @title.show new TitleEditor { @model }

    if @showAdminSection
      @admin.show new AdminSection { @model }

    @waitForPropCollection
    .then @showPropertiesEditor.bind(@)

    @listenTo @model, 'change', @updateNavigationButtons.bind(@)
    @updateNavigationButtons()

  showPropertiesEditor: ->
    @claims.show new PropertiesEditor
      collection: @properties
      propertiesShortlist: @model.propertiesShortlist

  serializeData: ->
    attrs = _.extend @model.toJSON(), @multiEditData()
    attrs.creationMode = @creationMode
    typePossessive = possessives[attrs.type]
    attrs.createAndShowLabel = "create and go to the #{typePossessive} page"
    attrs.returnLabel = "return to the #{typePossessive} page"
    attrs.creating = @model.creating
    attrs.canCancel = @canCancel()
    # Do not show the signal data error button in creation mode
    # as it wouldn't make sense
    attrs.signalDataErrorButton = not @creationMode
    return attrs

  multiEditData: ->
    data = {}
    { header, next, relation } = @options
    previous = @model.get('claims')[relation]
    if next? or previous?
      data.customHeader = customHeaders[header]
    if next?
      data.next = next
      data.progress = { current: 1, total: 2 }
    if previous?
      data.previous = previous
      data.progress = { current: 2, total: 2 }
    return data

  events:
    'click .entity-edit-cancel': 'cancel'
    'click .createAndShowEntity': 'createAndShowEntity'
    'click .createAndAddEntity': 'createAndAddEntity'
    'click #next': 'showNextMultiEditPage'
    'click #previous': 'showPreviousMultiEditPage'
    'click #signalDataError': 'signalDataError'

  # Criteria:
  # - Don't display a cancel button if we don't know where to redirect
  # - In the case of an entity being created, showing the entity page would fail
  # - Never display a cancel button when creating in mutliEdit mode as it means
  #   an entity wasn't found and redirected here, which means hitting a
  #   redirection loop
  canCancel: ->
    canCancelCase1 = @model.creating and not @multiEdit and window.history.length > 1
    canCancelCase2 = not @model.creating
    return canCancelCase1 or canCancelCase2

  cancel: ->
    if window.history.length > 1 then window.history.back()
    else app.execute 'show:entity:from:model', @model

  createAndShowEntity: -> @_createAndAction 'show:entity:from:model'
  createAndAddEntity: -> @_createAndAction 'show:entity:add:from:model'

  _createAndAction: (command)->
    @createPreviousAndUpdateCurrentModel()
    .then @model.create.bind(@model)
    .then app.Execute(command)
    .catch error_.Complete('.meta', false)
    .catch forms_.catchAlert.bind(null, @)

  signalDataError: (e)->
    uri = @model.get 'uri'
    subject = _.I18n  'data error'
    app.execute 'show:feedback:menu',
      subject: "[#{uri}][#{subject}] "
      event: e

  # Hiding navigation buttons when a label is required but no label is set yet
  # to invite the user to edit and save the label, or cancel.
  updateNavigationButtons: ->
    labelsCount = _.values(@model.get('labels')).length
    if @requiresLabel and labelsCount is 0
      unless @navigationButtonsDisabled
        @ui.navigationButtons.hide()
        @navigationButtonsDisabled = true
    else
      if @navigationButtonsDisabled
        @ui.navigationButtons.fadeIn()
        @navigationButtonsDisabled = false

  showNextMultiEditPage: ->
    { next } = @options
    { relation, labelTransfer } = next
    draftModel = serializeDraftModel @model
    next.claims[relation] = draftModel
    if labelTransfer? then next.claims[labelTransfer] = [ draftModel.label ]
    @navigateMultiEdit next

  showPreviousMultiEditPage: ->
    { relation } = @options
    previous = @model.get('claims')[relation]
    previous.next = serializeDraftModel @model, relation
    @navigateMultiEdit previous

  navigateMultiEdit: (data)->
    data.header = @options.header
    app.execute 'show:entity:create', data

  createPreviousAndUpdateCurrentModel: ->
    unless @previousData? then return _.preq.resolved
    @createPrevious()
    .then (previousEntityModel)=>
      claims = @model.get 'claims'
      # Replace the draft data object by the uri
      claims[@relation] = [ previousEntityModel.get('uri') ]
      @model.set 'claims', claims

  createPrevious: ->
    draftModel = entityDraftModel.create @previousData
    return draftModel.create()

# Matching entityDraftModel.create interface to allow to re-create the draft model
# from the URL
serializeDraftModel = (model, relation)->
  { labels, claims } = model.pick 'labels', 'claims'
  label = _.values(labels)[0]
  { type } = model
  # Omit the relation property to avoid conflict/cyclic references
  if relation? then claims = _.omit claims, relation
  return { type, claims, label, relation }

customHeaders =
  'new-work-and-edition': 'can you tell us more about this work and this particular edition?'

possessives =
  work: "book's"
  edition: "edition's"
  serie: "series'"
  human: "author's"
