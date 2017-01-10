TitleEditor = require './title_editor'
PropertiesEditor = require './properties_editor'
propertiesCollection = require 'modules/entities/lib/editor/properties_collection'
AdminSection = require './admin_section'

module.exports = Marionette.LayoutView.extend
  id: 'entityEdit'
  template: require './templates/entity_edit'
  behaviors:
    PreventDefault: {}

  regions:
    title: '.title'
    claims: '.claims'
    admin: '.admin'

  initialize: ->
    @userIsAdmin = app.user.get 'admin'
    @creationMode = @model.propertiesShortlist
    @showAdminSection = @userIsAdmin and not @creationMode
    @waitForPropCollection = @model.waitForSubentities.then @initPropertiesCollections.bind(@)

  initPropertiesCollections: -> @properties = propertiesCollection @model

  onShow: ->
    unless @model.type is 'edition'
      @title.show new TitleEditor { @model }

    if @showAdminSection
      @admin.show new AdminSection { @model }

    @waitForPropCollection
    .then @showPropertiesEditor.bind(@)

  showPropertiesEditor: ->
    @claims.show new PropertiesEditor
      collection: @properties
      propertiesShortlist: @model.propertiesShortlist

  serializeData: ->
    attrs = @model.toJSON()
    attrs.creationMode = @creationMode
    attrs.createAndReturnLabel = "create and return to the #{attrs.type}'s page"
    attrs.creating = @model.creating
    return attrs

  events:
    'click .createAndShowEntity': 'createAndShowEntity'
    'click .createAndAddEntity': 'createAndAddEntity'
    'click #signalDataError': 'signalDataError'

  createAndShowEntity: ->
    @model.create()
    .then app.Execute('show:entity:from:model')

  createAndAddEntity: ->
    @model.create()
    .then app.Execute('show:entity:add:from:model')

  signalDataError: (e)->
    uri = @model.get 'uri'
    subject = _.I18n  'data error'
    app.execute 'show:feedback:menu',
      subject: "[#{uri}][#{subject}] "
      event: e
