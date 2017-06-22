# Motivation for having a view separated from ItemShow:
# - no need to reload the image on re-render (like when details are saved)

ItemComments = require './item_comments'
ItemTransactions = require './item_transactions'
itemActions = require '../plugins/item_actions'
itemUpdaters = require '../plugins/item_updaters'
getActionKey = require 'lib/get_action_key'

module.exports = Marionette.LayoutView.extend
  id: 'itemShowData'
  template: require './templates/item_show_data'
  regions:
    transactionsRegion: '#transactions'
    # commentsRegion: '#comments'

  behaviors:
    ElasticTextarea: {}
    AlertBox: {}

  initialize: ->
    @lazyRender = _.LazyRender @
    @initPlugins()
    @uniqueSelector = '#'+@id
    # The alertbox is appended to the target's parent, which might have
    # historical reasons but seems a bit dumb now
    @alertBoxTarget = @uniqueSelector + ' .leftBox .panel'
    @listenTo @model, 'change', @lazyRender

  initPlugins: ->
    itemActions.call(@)
    itemUpdaters.call(@)

  onShow: ->
    setTimeout @preserveMinHeight.bind(@), 200

  # Allows to re-render without provoking a scroll jump because the view
  # suddenly takes less room vertically
  preserveMinHeight: ->
    # Add a margin to take in account details and notes form mode height
    minHeight = @$el.parent().height() + 30
    @$el.parent().css 'min-height', minHeight

  onRender: ->
    # @showComments()
    app.execute 'foundation:reload'
    if app.user.loggedIn then @showTransactions()

  events:
    'click a#editDetails': 'showDetailsEditor'
    'click .detailsPanel': 'showDetailsEditor'

    # show editor when focused and 'enter' is pressed
    'keydown .noteBox': 'showNotesEditorFromKey'
    'keydown .detailsPanel': 'showDetailsEditorFromKey'

    'keydown #detailsEditor': 'detailsEditorKeyAction'
    'click a#cancelDetailsEdition': 'hideDetailsEditor'
    'click a#validateDetails': 'validateDetails'
    'click a#editNotes': 'showNotesEditor'
    'click .noteBox': 'showNotesEditor'
    'click a#cancelNotesEdition': 'hideNotesEditor'
    'keydown #notesEditor': 'notesEditorKeyAction'
    'click a#validateNotes': 'validateNotes'
    'click a.requestItem': -> app.execute 'show:item:request', @model

  serializeData: -> @model.serializeData()

  # itemDestroy is in item_updaters
  itemDestroyBack: -> app.execute 'show:item:modal', @model
  afterDestroy: -> app.execute 'show:home'

  showNotesEditorFromKey: (e)->  @showEditorFromKey 'notes', e,
  showDetailsEditorFromKey: (e)-> @showEditorFromKey 'details', e,
  showEditorFromKey: (editor, e)->
    key = getActionKey e
    capitalizedEditor = _.capitaliseFirstLetter editor
    if key is 'enter' then @["show#{capitalizedEditor}Editor"]()

  showDetailsEditor: -> @showEditor 'details'
  hideDetailsEditor: -> @hideEditor 'details'
  detailsEditorKeyAction: (e)-> @editorKeyAction 'details', e

  showNotesEditor: -> @showEditor 'notes'
  hideNotesEditor: ->  @hideEditor 'notes'
  notesEditorKeyAction: (e)-> @editorKeyAction 'notes', e

  validateDetails: -> @validateEdit 'details'
  validateNotes: -> @validateEdit 'notes'

  showEditor: (nameBase)->
    unless @model.mainUserIsOwner then return
    $("##{nameBase}").hide()
    $("##{nameBase}Editor").show().find('textarea').focus()

  hideEditor: (nameBase)->
    $("##{nameBase}").show()
    $("##{nameBase}Editor").hide()

  editorKeyAction: (editor, e)->
    key = getActionKey e
    capitalizedEditor = _.capitaliseFirstLetter editor
    if key is 'esc'
      hideEditor = "hide#{capitalizedEditor}Editor"
      @[hideEditor]()
      e.stopPropagation()
    else if key is 'enter' and e.ctrlKey
      @validateEdit editor
      e.stopPropagation()

  validateEdit: (nameBase)->
    @hideEditor nameBase
    edited = $("##{nameBase}Editor textarea").val()
    if edited isnt @model.get(nameBase)
      app.request 'item:update',
        item: @model
        attribute: nameBase
        value: edited
        selector: "##{nameBase}Editor"

  # showComments:-> @commentsRegion.show new ItemComments { @model }

  showTransactions: ->
    @transactions ?= app.request 'get:transactions:ongoing:byItemId', @model.id
    Promise.all _.invoke(@transactions.models, 'beforeShow')
    .then => @transactionsRegion.show new ItemTransactions { collection: @transactions }

  afterDestroy: ->
    app.execute 'show:inventory:main:user'
