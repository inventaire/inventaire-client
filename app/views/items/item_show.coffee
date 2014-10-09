module.exports =  class ItemShow extends Backbone.Marionette.LayoutView
  template: require 'views/items/templates/item_show'
  serializeData: ->
    attrs = @model.serializeData()
    if attrs.pictures?.length > 1
      attrs.nextPictures = attrs.pictures.slice(1)
    return attrs
  regions:
    entityRegion: '#entity'
    editPanel: '#editPanel'
    pictureRegion: '#picture'
  behaviors:
    PreventDefault: {}
    ConfirmationModal: {}

  initialize: ->
    _.inspect(@)
    @model.on 'all', -> _.log arguments, 'item:show item events'
    @listenTo @model, 'change:comment', @render
    @listenTo @model, 'change:notes', @render
    @listenTo @model, 'add:pictures', @render

  onRender: ->
    # entity = @model.get 'entity'
    # if entity?.id?
    #   # ugly null null, but it's constrained by the scanner callback
    #   # returning /entity/:uri/add?:params
    #   app.execute 'show:entity', entity.id, null, null, @entityRegion

    @showPicture()
    @showItemEditionForm()

  showPicture: ->
    picture = new app.View.Behaviors.ChangePicture {model: @model}
    @pictureRegion.show picture

  showItemEditionForm: ->
    unless @model.restricted
      editForm = new app.View.ItemEditionForm {model: @model}
      @editPanel.show editForm

  events:
    'click a#destroy': 'itemDestroy'
    'click a#entity': 'showEntity'
    'click a#changePicture': 'changePicture'
    'click a#editComment, a#cancelCommentEdition': 'toggleCommentEditor'
    'click a#validateComment': 'validateComment'
    'click a#editNotes, a#cancelNotesEdition': 'toggleNotesEditor'
    'click a#validateNotes': 'validateNotes'

  itemEdit: -> app.execute 'show:item:form:edition', @model

  showEntity: -> app.execute 'show:entity', @model.get('suffix'), @model.get('title')

  changePicture: ->
    picturePicker = new app.View.Behaviors.PicturePicker {
      pictures: @model.get('pictures')
      limit: 3
      save: (value)=>
        app.request 'item:update',
          item: @model
          attribute: 'pictures'
          value: value
    }
    app.layout.modal.show picturePicker

  itemDestroy: ->
    app.request 'item:destroy',
      model: @model
      selector: @el
      next: -> app.execute 'show:home'


  toggleCommentEditor: ->
    @toggleEditor('comment')

  validateComment: ->
    @validateEdit('comment')

  toggleNotesEditor: ->
    @toggleEditor('notes')

  validateNotes: ->
    @validateEdit('notes')

  toggleEditor: (nameBase)->
    $("##{nameBase}").toggle()
    $("##{nameBase}Editor").toggle()

  validateEdit: (nameBase)->
    @toggleEditor(nameBase)
    _.log nameBase, 'nameBase'
    _.log "##{nameBase} textarea"
    edited = $("##{nameBase}Editor textarea").val()
    console.log edited
    console.log edited isnt @model.get(nameBase)
    if edited isnt @model.get(nameBase)
      app.request 'item:update',
        item: @model
        attribute: nameBase
        value: edited
        selector: "##{nameBase}Editor"