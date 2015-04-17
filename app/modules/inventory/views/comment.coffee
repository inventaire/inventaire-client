forms_ = require 'modules/general/lib/forms'

module.exports = Marionette.ItemView.extend
  template: require './templates/comment'
  className: "comment #{@cid}"
  serializeData: ->
    attrs = @model.toJSON()
    attrs.cid = @cid
    attrs.user = @userData(attrs.user)
    return attrs

  userData: (userId)->
    app.request('get:userModel:from:userId', userId)?.toJSON()

  behaviors:
    AlertBox: {}
    ConfirmationModal: {}
    ElasticTextarea: {}

  initialize: ->
    @uniqueSelector = "#{@cid}"
    @listenTo @model, 'change', @render

  ui:
    core: '.core'
    displayed: 'span.message'
    editor: 'textarea.message'
    menu: '.icon-buttons'

  events:
    'click .edit': 'editComment'
    'click .delete': 'requestDeletion'
    'click .cancelButton': 'toggleEditMode'
    'keyup textarea.message': 'escapeEditMode'
    'click .saveButton': 'saveEdit'


  onShow: ->
    app.execute 'foundation:reload'

  editComment: ->
    @toggleEditMode()
    @ui.editor.focus()

  requestDeletion: ->
    app.request 'comments:delete', @model, @

  escapeEditMode: (e)->
    if _.escapeKeyPressed(e) then @toggleEditMode()

  toggleEditMode: ->
    @ui.core.toggle()
    @ui.menu.toggle()

  saveEdit: ->
    newMessage = @ui.editor.val()
    app.request 'comments:update', @model, newMessage
    # .then @toggleEditMode.bind(@)
    .catch @saveFail.bind(@, newMessage)

  saveFail: (newMessage, err)->
    # @toggleEditMode()
    # @ui.editor.val newMessage
    err.selector = 'textarea.message'
    forms_.alert(@, err)
