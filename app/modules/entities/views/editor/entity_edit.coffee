TitleEditor = require './title_editor'
PropertiesEditor = require './properties_editor'
propertiesCollection = require 'modules/entities/lib/editor/properties_collection'
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

  ui:
    mergeWithInput: '#mergeWithField'

  initialize: ->
    @userIsAdmin = app.user.get 'admin'
    @creationMode = @model.propertiesShortlist
    @waitForPropCollection = @model.waitForSubentities.then @initPropertiesCollections.bind(@)

  initPropertiesCollections: -> @properties = propertiesCollection @model

  onShow: ->
    unless @model.type is 'edition'
      @title.show new TitleEditor { @model }

    @waitForPropCollection
    .then @showPropertiesEditor.bind(@)

  showPropertiesEditor: ->
    @claims.show new PropertiesEditor
      collection: @properties
      propertiesShortlist: @model.propertiesShortlist

  serializeData: ->
    attrs = @model.toJSON()
    attrs.creationMode = @creationMode
    attrs.userIsAdmin = @userIsAdmin
    attrs.creating = @model.creating
    if @userIsAdmin then attrs.mergeWith = mergeWithData
    return attrs

  events:
    'click .createAndShowEntity': 'createAndShowEntity'
    'click .createAndAddEntity': 'createAndAddEntity'
    'click #mergeWithButton': 'merge'
    'click #signalDataError': 'signalDataError'

  createAndShowEntity: ->
    @model.create()
    .then app.Execute('show:entity:from:model')

  createAndAddEntity: ->
    @model.create()
    .then app.Execute('show:entity:add:from:model')

  merge: (e)->
    fromUri = @model.get 'uri'
    toUri = @ui.mergeWithInput.val()
    # send to merge endpoint as everything should happen server side now
    _.preq.put app.API.entities.merge,
      from: fromUri
      to: toUri
    .then showRedirectedEntity.bind(null, fromUri, toUri)
    .catch error_.Complete('#mergeWithField', false)
    .catch forms_.catchAlert.bind(null, @)

  signalDataError: (e)->
    uri = @model.get 'uri'
    subject = _.I18n  'data error'
    app.execute 'show:feedback:menu',
      subject: "[#{uri}][#{subject}] "
      event: e

showRedirectedEntity = (fromUri, toUri)->
  # Get the refreshed, redirected entity
  # thus also updating entitiesModelsIndexedByUri
  app.request 'get:entity:model', fromUri, true
  .then app.Execute('show:entity:from:model')

mergeWithData =
  nameBase: 'mergeWith'
  field:
    placeholder: 'ex: wd:Q237087'
    dotdotdot: ''
  button:
    text: 'merge'
    classes: 'light-blue bold postfix'
