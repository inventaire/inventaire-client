TitleEditor = require './title_editor'
PropertiesEditor = require './properties_editor'
propertiesCollection = require 'modules/entities/lib/editor/properties_collection'
AdminSection = require './admin_section'
forms_ = require 'modules/general/lib/forms'
error_ = require 'lib/error'

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
    creationButtons: '.creationButton'

  initialize: ->
    @userIsAdmin = app.user.get 'admin'
    @creationMode = @model.propertiesShortlist
    @requiresLabel = @model.type isnt 'edition'
    @showAdminSection = @userIsAdmin and not @creationMode
    @waitForPropCollection = @model.waitForSubentities.then @initPropertiesCollections.bind(@)
    @creationButtonDisabled = false

  initPropertiesCollections: -> @properties = propertiesCollection @model

  onShow: ->
    if @requiresLabel
      @title.show new TitleEditor { @model }

    if @showAdminSection
      @admin.show new AdminSection { @model }

    @waitForPropCollection
    .then @showPropertiesEditor.bind(@)

    @listenTo @model, 'change', @updateCreationButtons.bind(@)
    @updateCreationButtons()

  showPropertiesEditor: ->
    @claims.show new PropertiesEditor
      collection: @properties
      propertiesShortlist: @model.propertiesShortlist

  serializeData: ->
    attrs = @model.toJSON()
    attrs.creationMode = @creationMode
    attrs.createAndReturnLabel = "create and return to the #{attrs.type}'s page"
    attrs.creating = @model.creating
    attrs.canCancel = @canCancel()
    return attrs

  events:
    'click .cancel': 'cancel'
    'click .createAndShowEntity': 'createAndShowEntity'
    'click .createAndAddEntity': 'createAndAddEntity'
    'click #signalDataError': 'signalDataError'

  # Don't display a cancel button if we don't know where to redirect
  # In the case of an entity being created, showing the entity page would fail
  canCancel: -> window.history.length > 1 or @model.creating

  cancel: ->
    if window.history.length > 1 then window.history.back()
    else app.execute 'show:entity:from:model', @model

  createAndShowEntity: -> @_createAndAction 'show:entity:from:model'
  createAndAddEntity: -> @_createAndAction 'show:entity:add:from:model'

  _createAndAction: (command)->
    @model.create()
    .then app.Execute(command)
    .catch error_.Complete('.meta', false)
    .catch forms_.catchAlert.bind(null, @)

  signalDataError: (e)->
    uri = @model.get 'uri'
    subject = _.I18n  'data error'
    app.execute 'show:feedback:menu',
      subject: "[#{uri}][#{subject}] "
      event: e

  # Hiding creation buttons when a label is required but no label is set yet
  # to invite the user to edit and save the label, or cancel.
  updateCreationButtons: ->
    labelsCount = _.values(@model.get('labels')).length
    if @requiresLabel and labelsCount is 0
      unless @creationButtonDisabled
        @ui.creationButtons.hide()
        @creationButtonDisabled = true
    else
      if @creationButtonDisabled
        @ui.creationButtons.fadeIn()
        @creationButtonDisabled = false
