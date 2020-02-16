LabelsEditor = require './labels_editor'
PropertiesEditor = require './properties_editor'
propertiesCollection = require '../../lib/editor/properties_collection'
AdminSection = require './admin_section'
forms_ = require 'modules/general/lib/forms'
error_ = require 'lib/error'
properties = require 'modules/entities/lib/properties'
{ unprefixify } = require 'lib/wikimedia/wikidata'
moveToWikidata = require './lib/move_to_wikidata'
{ startLoading } = require 'modules/general/plugins/behaviors'
error_ = require 'lib/error'

module.exports = Marionette.LayoutView.extend
  id: 'entityEdit'
  template: require './templates/entity_edit'
  behaviors:
    AlertBox: {}
    Loading: {}
    PreventDefault: {}

  regions:
    title: '.title'
    claims: '.claims'
    admin: '.admin'

  ui:
    navigationButtons: '.navigationButtons'

  initialize: ->
    @creationMode = @model.creating
    @requiresLabel = @model.type isnt 'edition'
    @canBeAddedToInventory = @model.type in inventoryTypes
    @showAdminSection = app.user.isAdmin and not @creationMode

    if @model.subEntitiesInverseProperty?
      @waitForPropCollection = @model.fetchSubEntities()
        .then @initPropertiesCollections.bind(@)
    else
      @initPropertiesCollections()
      @waitForPropCollection = Promise.resolve()

    @navigationButtonsDisabled = false

  initPropertiesCollections: -> @properties = propertiesCollection @model

  onShow: ->
    if @requiresLabel
      @title.show new LabelsEditor { @model }

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
    attrs = @model.toJSON()
    attrs.creationMode = @creationMode
    typePossessive = possessives[attrs.type]
    attrs.createAndShowLabel = "create and go to the #{typePossessive} page"
    attrs.returnLabel = "return to the #{typePossessive} page"
    attrs.creating = @model.creating
    attrs.canCancel = @canCancel()
    attrs.isAdmin = app.user.isAdmin
    attrs.moveToWikidata = @moveToWikidataData()
    # Do not show the signal data error button in creation mode
    # as it wouldn't make sense
    attrs.signalDataErrorButton = not @creationMode
    # Used when item_show attempts to 'preciseEdition' with a new edition
    attrs.itemToUpdate = @itemToUpdate
    attrs.canBeAddedToInventory = @canBeAddedToInventory
    return attrs

  events:
    'click .entity-edit-cancel': 'cancel'
    'click .createAndShowEntity': 'createAndShowEntity'
    'click .createAndAddEntity': 'createAndAddEntity'
    'click .createAndUpdateItem': 'createAndUpdateItem'
    'click #signalDataError': 'signalDataError'
    'click #moveToWikidata': 'moveToWikidata'

  canCancel: ->
    # In the case of an entity being created, showing the entity page would fail
    unless @model.creating then return true
    # Don't display a cancel button if we don't know where to redirect
    return Backbone.history.last.length > 0

  cancel: ->
    fallback = => app.execute 'show:entity:from:model', @model
    app.execute 'history:back', { fallback }

  createAndShowEntity: ->
    @_createAndAction app.Execute('show:entity:from:model')

  createAndAddEntity: ->
    @_createAndAction app.Execute('show:entity:add:from:model')

  createAndUpdateItem: ->
    { itemToUpdate } = @
    if itemToUpdate instanceof Backbone.Model
      @_createAndUpdateItem itemToUpdate
    else
      # If the view was loaded from the URL, @itemToUpdate will be just
      # the URL persisted attributes instead of a model object
      app.request 'get:item:model', @itemToUpdate._id
      .then @_createAndUpdateItem.bind(@)

  _createAndUpdateItem: (item)->
    action = (entity)-> app.request 'item:update:entity', item, entity
    @_createAndAction action

  _createAndAction: (action)->
    @beforeCreate()
    .then @model.create.bind(@model)
    .then action
    .catch error_.Complete('.meta', false)
    .catch forms_.catchAlert.bind(null, @)

  # Override in sub views
  beforeCreate: -> Promise.resolve()

  signalDataError: (e)->
    uri = @model.get 'uri'
    subject = _.I18n  'data error'
    app.execute 'show:feedback:menu',
      subject: "[#{uri}][#{subject}] "
      uris: [ uri ]
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

  moveToWikidataData: ->
    uri = @model.get 'uri'

    # An entity being created on Inventaire won't have a URI at this point
    if not uri? or isWikidataUri(uri) then return

    type = @model.get 'type'
    if type is 'edition'
      reason = _.i18n "editions can't be moved to Wikidata for the moment"
      return { ok: false, reason }

    for property, values of @model.get('claims')
      # Known case where properties[property] is undefined: wdt:P31
      if properties[property]?.editorType is 'entity'
        for value in values
          unless isWikidataUri value
            message = _.i18n "some values aren't Wikidata entities:"
            reason = "#{message} #{_.i18n(unprefixify(property))}"
            return { ok: false, reason }

    return { ok: true }

  moveToWikidata: ->
    unless app.user.hasWikidataOauthTokens()
      return app.execute 'show:wikidata:edit:intro:modal', @model

    startLoading.call @, '#moveToWikidata'

    uri = @model.get('uri')
    moveToWikidata uri
    # This should now redirect us to the new Wikidata edit page
    .then -> app.execute 'show:entity:edit', uri
    .catch error_.Complete('#moveToWikidata', false)
    .catch forms_.catchAlert.bind(null, @)

isWikidataUri = (uri)-> uri.split(':')[0] is 'wd'

possessives =
  work: "book's"
  edition: "edition's"
  serie: "series'"
  human: "author's"
  publisher: "publisher's"

inventoryTypes = [ 'work', 'edition' ]
