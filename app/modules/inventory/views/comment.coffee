forms_ = require 'modules/general/lib/forms'
getActionKey = require 'lib/get_action_key'

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
    'dblclick span.message': 'editCommentIfMobile'

  onShow: ->
    app.execute 'foundation:reload'

  editComment: ->
    @toggleEditMode()
    @ui.editor.focus()

  editCommentIfMobile: ->
    if _.isMobile then @editComment()

  requestDeletion: ->
    app.request 'comments:delete', @model, @

  # TODO: implement to allow coming back from the delete modal
  # deleteCommentBack: ->

  escapeEditMode: (e)->
    key = getActionKey e
    switch key
      when 'esc' then @toggleEditMode()

  toggleEditMode: ->
    @trigger 'edit:toggle'
    @ui.core.toggle()
    @ui.menu.toggle()

  saveEdit: ->
    newMessage = @ui.editor.val()
    app.request 'comments:update', @model, newMessage
    # .then @toggleEditMode.bind(@)
    .catch @saveFail.bind(@, newMessage)
    @trigger 'edit:toggle'

  saveFail: (newMessage, err)->
    # @toggleEditMode()
    # @ui.editor.val newMessage
    err.selector = 'textarea.message'
    forms_.alert(@, err)
