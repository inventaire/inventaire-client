# Motivation for having a view separated from ItemShow:
# - no need to reload the image on re-render (like when details are saved)

ItemTransactions = require './item_transactions'
getActionKey = require 'lib/get_action_key'
ItemShelves = require './item_shelves'

module.exports = ItemLayout.extend
  id: 'itemShowData'
  template: require './templates/item_show_data'
  regions:
    transactionsRegion: '#transactions'
    shelvesSelector: '#shelvesSelector'

  behaviors:
    ElasticTextarea: {}
    AlertBox: {}

  initialize: ->
    # The alertbox is appended to the target's parent, which might have
    # historical reasons but seems a bit dumb now
    @alertBoxTarget = '.leftBox .panel'

  modelEvents:
    'change:notes': 'lazyRender'
    'change:details': 'lazyRender'

  onRender: ->
    if app.user.loggedIn then @showTransactions()

  events:
    'click a.transaction': 'updateTransaction'
    'click a.listing': 'updateListing'
    'click a.remove': 'itemDestroy'
    'click a.itemShow': 'itemShow'
    'click a.user': 'showUser'
    'click a.showUser': 'showUser'
    'click a.mainUserRequested': 'showTransaction'

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
    'click .shelvesPanel': -> @showShelves()

  serializeData: ->
    attrs = @model.serializeData()
    _.extend attrs,
      shelves: @model.get('shelves')

  itemDestroyBack: ->
    if @model.isDestroyed then app.execute 'modal:close'
    else app.execute 'show:item', @model

  showNotesEditorFromKey: (e)->  @showEditorFromKey 'notes', e,
  showDetailsEditorFromKey: (e)-> @showEditorFromKey 'details', e,
  showEditorFromKey: (editor, e)->
    key = getActionKey e
    capitalizedEditor = _.capitalise editor
    if key is 'enter' then @["show#{capitalizedEditor}Editor"]()

  showDetailsEditor: (e)-> @showEditor 'details', e
  hideDetailsEditor: (e)-> @hideEditor 'details', e
  detailsEditorKeyAction: (e)-> @editorKeyAction 'details', e

  showNotesEditor: (e)-> @showEditor 'notes', e
  hideNotesEditor: (e)->  @hideEditor 'notes', e
  notesEditorKeyAction: (e)-> @editorKeyAction 'notes', e

  validateDetails: -> @validateEdit 'details'
  validateNotes: -> @validateEdit 'notes'

  showEditor: (nameBase, e)->
    unless @model.mainUserIsOwner then return
    $("##{nameBase}").hide()
    $("##{nameBase}Editor").show().find('textarea').focus()
    e?.stopPropagation()

  hideEditor: (nameBase, e)->
    $("##{nameBase}").show()
    $("##{nameBase}Editor").hide()
    e?.stopPropagation()

  editorKeyAction: (editor, e)->
    key = getActionKey e
    capitalizedEditor = _.capitalise editor
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
      app.request 'items:update',
        items: [ @model ]
        attribute: nameBase
        value: edited
        selector: "##{nameBase}Editor"

  showTransactions: ->
    @transactions ?= app.request 'get:transactions:ongoing:byItemId', @model.id
    Promise.all _.invoke(@transactions.models, 'beforeShow')
    .then @ifViewIsIntact('_showTransactions')

  showShelves: ->
    _.preq.get app.API.shelves.byOwners(app.user.id)
    .get 'shelves'
    .then (shelvesObj) =>
      shelves = _.values shelvesObj
      @shelves = new Backbone.Collection shelves
    .then @ifViewIsIntact('_showShelves')

  _showShelves: ->
    @shelvesSelector.show new ItemShelves { collection: @shelves, item: @model }

  _showTransactions: ->
    @transactionsRegion.show new ItemTransactions { collection: @transactions }

  afterDestroy: ->
    app.execute 'show:inventory:main:user'
