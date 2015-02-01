module.exports = class EntityCreate extends Backbone.Marionette.ItemView
  template: require './templates/entity_create'
  className: 'entityCreate'
  events:
    'click #addPicture': 'addPicture'
    'click #addToInventory, #inventorying': 'inventorying'
    'click #giving': 'giving'
    'click #lending': 'lending'
    'click #selling': 'selling'
    'keyup #title': 'updateTitle'
    'keyup #authors': 'updateAuthors'
    'keyup #isbn': 'updateIsbn'

  ui:
    title: '#title'
    authors: '#authors'
    isbn: '#isbn'

  initialize: ->
    @initModel()
    @initUpdater()

  initModel: ->
    @model = new Backbone.Model
    @model.set 'pictures', []
    @listenTo @model, 'change:pictures', @render
    _.inspect(@)

  initUpdater: ->
    @updateTitle = @lazyUpdate('title')
    @updateAuthors = @lazyUpdate('authors')
    @updateIsbn = @lazyUpdate('isbn')

  lazyUpdate: (attr)-> _.debounce @updateModel.bind(@, attr), 250
  updateModel: (attr)->
    val = @ui[attr].val()
    @model.set attr, val

  onShow: -> @suggestQueryAsTitle()

  suggestQueryAsTitle: ->
    {data} = @options
    @ui.title.val data
    @model.set('title', data)

  addPicture: ->
    picturePicker = new app.View.Behaviors.PicturePicker
      pictures: @model.get('pictures')
      limit: 3
      save: (pictures)=> @model.set('pictures', pictures)

    app.layout.modal.show picturePicker

  giving: -> @showItemCreation 'giving'
  lending: -> @showItemCreation 'lending'
  selling: -> @showItemCreation 'selling'
  inventorying: -> @showItemCreation 'inventorying'

  showItemCreation: (transaction)->
    @createEntity()
    .then (entityModel)->
      params =
        entity: entityModel
        transaction: transaction
      _.log params, 'item:creation:params'
      app.execute 'show:item:creation:form', params
    .catch (err)-> _.log err, 'showItemCreation err'

  createEntity: ->
    entityData = @normalizeEntityData()
    return app.request 'create:entity', entityData

  normalizeEntityData: ->
    data = @model.toJSON()
    entity =
      title: data.title.trim()
      authors: data.authors?.split(',').map (str)-> str.trim()
      isbn: data.isbn?.trim()
      pictures: data.pictures

    return _.log entity, 'entity?'
