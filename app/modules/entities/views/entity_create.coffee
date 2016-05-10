books_ = require 'lib/books'
forms_ = require 'modules/general/lib/forms'
entityDataTests = require '../lib/inv/entity_data_tests'
EntityActions = require './entity_actions'
PicturePicker = require 'modules/general/views/behaviors/picture_picker'
# authorsSource = require '../lib/authors_source'
createEntities = require '../lib/create_entities'

module.exports = Marionette.LayoutView.extend
  template: require './templates/entity_create'
  className: ->
    if @options.standalone then 'entityCreate standalone'
    else 'entityCreate'
  regions:
    entityActions: '#entityActions'

  events:
    'click #addPicture': 'addPicture'

  ui:
    title: '#titleField'
    authors: '#authorsField'
    autocomplete: '#authorsField'
    isbn: '#isbnField'

  behaviors:
    AlertBox: {}
    BackupForm: {}
    # AutoComplete: {}

  initialize: ->
    @initModel()

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
    if @options.standalone then header = "this book isn't in the database: #{header}"
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

  onRender: ->
    @showEntityActions()

  onShow: ->
    @prefillForm()
    if @options.standalone then @ui.title.focus()

  prefillForm: ->
    { data } = @options
    if data?
      if books_.isIsbn data
        @ui.isbn.val data
        @model.set 'isbn', data
      else
        @ui.title.val data
        @model.set 'title', data

  addPicture: ->
    picturePicker = new PicturePicker
      pictures: @model.get 'pictures'
      # limit: 3
      limit: 1
      save: @model.set.bind @model, 'pictures'

    app.layout.modal.show picturePicker

  showItemCreation: (transaction)->
    _.preq.start
    .then @createEntity.bind(@)
    .then @showItemCreationForm.bind(@, transaction)
    .catch forms_.catchAlert.bind(null, @)

  createEntity: ->
    title = @ui.title.val()
    author = @ui.authors.attr('data-autocomplete-value')
    # TODO:
    # - re-integrate isbn (via createEntities.bookEdition)
    # - re-integrate the pictures: pictures = @model.get 'pictures'
    # - re-integrate value validation and form errors
    # - allow multiple authors
    return createEntities.book title, [author], null, app.user.lang

  showItemCreationForm: (transaction, entityModel)->
    app.execute 'show:item:creation:form',
      entity: entityModel
      transaction: transaction

  showEntityActions: ->
    @entityActions.show new EntityActions {model: @model}
