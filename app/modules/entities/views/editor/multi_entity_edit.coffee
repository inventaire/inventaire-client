EntityEdit = require './entity_edit'
entityDraftModel = require '../../lib/entity_draft_model'

module.exports = EntityEdit.extend
  initialize: ->
    EntityEdit::initialize.call @
    { @next, @previous, @relation, @fromIsbn } = @options

  serializeData: ->
    _.extend EntityEdit::serializeData.call(@), @multiEditData()

  multiEditData: ->
    data = {}
    if @fromIsbn?
      data.header = _.i18n 'can you tell us more about this work and this particular edition?'
      data.headerContext = 'ISBN: ' + @fromIsbn
    if @next?
      data.next = @next
      data.progress = { current: 1, total: 2 }
    if @previous?
      data.previous = @previous
      data.progress = { current: 2, total: 2 }
    return data

  events: _.extend {}, EntityEdit::events,
    'click #next': 'showNextMultiEditPage'
    'click #previous': 'showPreviousMultiEditPage'

  showNextMultiEditPage: ->
    { next } = @options
    { relation, labelTransfer } = next
    draftModel = serializeDraftModel @model
    next.previous = draftModel
    if labelTransfer? then next.claims[labelTransfer] = [ draftModel.label ]
    @navigateMultiEdit next

  showPreviousMultiEditPage: ->
    { relation } = @options
    @previous.next = serializeDraftModel @model, relation
    @navigateMultiEdit @previous

  navigateMultiEdit: (data)->
    data.fromIsbn = @options.fromIsbn
    app.execute 'show:entity:create', data

  # Never display a cancel button when creating in mutliEdit mode as it means
  # an entity wasn't found and redirected here, which means hitting a
  # redirection loop
  canCancel: -> false

  beforeCreate: -> @createPreviousAndUpdateCurrentModel()

  createPreviousAndUpdateCurrentModel: ->
    @createPrevious()
    .then (previousEntityModel)=>
      claims = @model.get 'claims'
      # Replace the draft data object by the uri
      claims[@relation] = [ previousEntityModel.get('uri') ]
      @model.set 'claims', claims

  createPrevious: ->
    draftModel = entityDraftModel.create @previous
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
