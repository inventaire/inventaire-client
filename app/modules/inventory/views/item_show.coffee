ItemEditionForm = require './item_edition_form'
ItemComments = require './item_comments'
EntityData = require 'modules/entities/views/entity_data'
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
    commentsRegion: '#comments'

  behaviors:
    ConfirmationModal: {}
    ElasticTextarea: {}

  initialize: ->
    @initPlugins()
    @uniqueSelector = '#'+@id
    @model.on 'all', -> _.log arguments, 'item:show item events'
    @listenTo @model, 'change:details', @render
    @listenTo @model, 'change:notes', @render
    @listenTo @model, 'add:pictures', @render

  initPlugins: -> itemUpdaters.call(@)

  onRender: ->
    @showEntityData()
    @showPicture()
    # @showItemEditionForm()
    app.execute('foundation:reload')
    @showComments()

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

  # showItemEditionForm: ->
  #   unless @model.restricted
  #     editForm = new ItemEditionForm {model: @model}
  #     @editPanel.show editForm

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
