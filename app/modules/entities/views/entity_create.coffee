books_ = app.lib.books
forms_ = require 'modules/general/lib/forms'
entityDataTests = require '../lib/inv/entity_data_tests'
EntityActions = require './entity_actions'

module.exports = Marionette.LayoutView.extend
  template: require './templates/entity_create'
  className: ->
    if @options.standalone then 'entityCreate standalone'
    else 'entityCreate'
  regions:
    entityActions: '#entityActions'

  events:
    'click #addPicture': 'addPicture'
    'keyup #titleField': 'updateTitle'
    'keyup #authorsField': 'updateAuthors'
    'keyup #isbnField': 'updateIsbn'

  ui:
    title: '#titleField'
    authors: '#authorsField'
    isbn: '#isbnField'

  behaviors:
    AlertBox: {}

  initialize: ->
    @initModel()
    @initUpdater()

  serializeData: ->
    _.extend @model.toJSON(),
      header: @getHeader()
      titleField: @fieldData 'title', 'ex: Hamlet'
      authorsField: @fieldData 'authors', 'ex: William Shakespeare'
      isbnField: @fieldData 'isbn', 'ex: 978-2070368228'
      standalone: @options.standalone

  getHeader: ->
    header = "let's just create the book card"
    if @options.secondChoice then header = "otherwise, #{header}"
    if @options.standalone then header = "this book isnt in the database: #{header}"
    return _.i18n header

  fieldData: (attr, placeholder)->
    id: attr
    value: @model.get attr
    placeholder: placeholder

  initModel: ->
    @model = new Backbone.Model
    @model.set 'pictures', []
    @listenTo @model, 'change:pictures', @render

    # let entity_actions view listen for click ##{transaction} events
    # but take back control then to do the custom logic implied by
    # having possible forms errors to handle and having to create the entity
    @model.delegateItemCreation = true
    @listenTo @model, 'delegate:item:creation', @showItemCreation.bind(@)

  initUpdater: ->
    @updateTitle = @lazyUpdate 'title'
    @updateAuthors = @lazyUpdate 'authors'
    @updateIsbn = @lazyUpdate 'isbn'

  lazyUpdate: (attr)-> _.debounce @updateModel.bind(@, attr), 250
  updateModel: (attr)->
    val = @ui[attr].val()
    @model.set attr, val

  onRender: ->
    @showEntityActions()

  onShow: ->
    @prefillForm()

  prefillForm: ->
    {data} = @options
    if data?
      if books_.isIsbn data
        @ui.isbn.val data
        @model.set 'isbn', data
      else
        @ui.title.val data
        @model.set 'title', data

  addPicture: ->
    picturePicker = new app.View.Behaviors.PicturePicker
      pictures: @model.get 'pictures'
      limit: 3
      save: @model.set.bind @model, 'pictures'

    app.layout.modal.show picturePicker

  showItemCreation: (transaction)->
    _.preq.start()
    .then @createEntity.bind(@)
    .then @showItemCreationForm.bind(@, transaction)
    .catch forms_.catchAlert.bind(null, @)

  createEntity: ->
    entityData = @normalizeEntityData()
    return app.request 'create:entity', entityData

  normalizeEntityData: ->
    entityData = @model.toJSON()
    entityDataTests entityData
    { title, authors, isbn, pictures } = entityData

    entity =
      title: title.trim()
      authors: authors?.split(',').map (str)-> str.trim()
      pictures: pictures

    if isbn? then entity.isbn = books_.normalizeIsbn isbn

    return _.log entity, 'entity?'

  showItemCreationForm: (transaction, entityModel)->
    app.execute 'show:item:creation:form',
      entity: entityModel
      transaction: transaction

  showEntityActions: ->
    @entityActions.show new EntityActions {model: @model}
