module.exports =  class ItemShow extends Backbone.Marionette.LayoutView
  template: require 'views/items/templates/item_show'
  serializeData: -> @model.serializeData()
  regions:
    entityRegion: '#entity'
    editPanel: '#editPanel'
    pictureRegion: '#picture'
  behaviors:
    PreventDefault: {}
    ConfirmationModal: {}

  initialize: ->
    @model.on 'all', -> _.log arguments, 'item:show item events'
    @listenTo @model, 'change:comment', @render

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
    'click a#editComment': 'toggleEditor'
    'click a#validateComment': 'validateComment'
    'click a#cancelCommentEdition': 'toggleEditor'

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

  toggleEditor: ->
    $('#comment').toggle()
    $('#commentEditor').toggle()

  validateComment: (e)->
    @toggleEditor()
    newComment = $('#commentEditor textarea').val()
    if newComment isnt comment
      app.request 'item:update',
        item: @model
        attribute: 'comment'
        value: newComment
        selector: '#commentEditor'