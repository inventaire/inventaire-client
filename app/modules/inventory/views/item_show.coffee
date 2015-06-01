ItemComments = require './item_comments'
ItemTransactions = require './item_transactions'
EntityData = require 'modules/entities/views/entity_data'
itemActions = require '../plugins/item_actions'
itemUpdaters = require '../plugins/item_updaters'

module.exports =  ItemShow = Backbone.Marionette.LayoutView.extend
  id: 'itemShowLayout'
  template: require './templates/item_show'
  serializeData: ->
    attrs = @model.serializeData()
    _.extend attrs,
      nextPictures: @nextPicturesData(attrs)

  nextPicturesData: (attrs)->
    if attrs.pictures?.length > 1
      return attrs.pictures.slice(1)

  regions:
    entityRegion: '#entity'
    pictureRegion: '#picture'
    transactionsRegion: '#transactions'
    commentsRegion: '#comments'

  behaviors:
    PreventDefault: {}
    ConfirmationModal: {}
    ElasticTextarea: {}

  initialize: ->
    _.log @model, 'item_show model'
    @initPlugins()
    @uniqueSelector = '#'+@id
    @model.on 'all', -> _.log arguments, 'item:show item events'
    @listenTo @model, 'change:details', @render
    @listenTo @model, 'change:notes', @render
    @listenTo @model, 'add:pictures', @render

  initPlugins: ->
    itemActions.call(@)
    itemUpdaters.call(@)

  onRender: ->
    @showEntityData()
    @showPicture()
    app.execute('foundation:reload')
    @showComments()

  onShow: ->
    @showTransactions()

  showEntityData: ->
    { entityModel } = @model
    if entityModel? then @showEntityModel(entityModel)
    else @listenTo @model, 'entity:ready', @showEntityModel.bind(@)

  showEntityModel: (entityModel)->
    @entityRegion.show new EntityData
      model: entityModel
      hidePicture: true

  showPicture: ->
    picture = new app.View.Behaviors.ChangePicture {model: @model}
    @pictureRegion.show picture

  events:
    'click a#destroy': 'itemDestroy'
    'click a#changePicture': 'changePicture'
    'click a#editDetails, a#cancelCommentEdition': 'toggleDetailsEditor'
    'click a#validateDetails': 'validateDetails'
    'click a#editNotes, a#cancelNotesEdition': 'toggleNotesEditor'
    'click a#validateNotes': 'validateNotes'

  itemEdit: -> app.execute 'show:item:form:edition', @model

  changePicture: ->
    picturePicker = new app.View.Behaviors.PicturePicker
      pictures: @model.get('pictures')
      limit: 3
      save: @savePicture.bind(@)
    app.layout.modal.show picturePicker

  savePicture: (value)->
    app.request 'item:update',
      item: @model
      attribute: 'pictures'
      value: value

  itemDestroy: ->
    app.request 'item:destroy',
      model: @model
      selector: @uniqueSelector
      next: -> app.execute 'show:home'


  toggleDetailsEditor: -> @toggleEditor('details')
  toggleNotesEditor: -> @toggleEditor('notes')

  validateDetails: -> @validateEdit('details')
  validateNotes: -> @validateEdit('notes')

  toggleEditor: (nameBase)->
    $("##{nameBase}").toggle()
    $("##{nameBase}Editor").toggle()

  validateEdit: (nameBase)->
    @toggleEditor(nameBase)
    edited = $("##{nameBase}Editor textarea").val()
    if edited isnt @model.get(nameBase)
      app.request 'item:update',
        item: @model
        attribute: nameBase
        value: edited
        selector: "##{nameBase}Editor"

  showComments:->
    @commentsRegion.show new ItemComments { model: @model }

  showTransactions: ->
    transactions = app.request 'get:transactions:byItemId', @model.id
    @transactionsRegion.show new ItemTransactions { collection: transactions }
