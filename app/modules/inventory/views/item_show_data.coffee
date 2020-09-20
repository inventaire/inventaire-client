# Motivation for having a view separated from ItemShow:
# - no need to reload the image on re-render (like when details are saved)

ItemTransactions = require './item_transactions'
getActionKey = require 'lib/get_action_key'
ItemShelves = require './item_shelves'
ShelvesList = require 'modules/shelves/views/shelves_list'
Shelves = require 'modules/shelves/collections/shelves'
{ getShelvesByOwner, getByIds: getShelvesByIds } = require 'modules/shelves/lib/shelves'
itemViewsCommons = require '../lib/items_views_commons'
ItemLayout = Marionette.LayoutView.extend itemViewsCommons

module.exports = ItemLayout.extend
  id: 'itemShowData'
  template: require './templates/item_show_data'
  regions:
    transactionsRegion: '#transactions'
    shelvesSelector: '#shelvesSelector'

  ui:
    shelvesPanel: '.shelvesPanel'
    toggleShelvesExpand: '.toggleShelvesExpand'

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
    'change:shelves': 'updateShelves'
    'add:shelves': 'updateShelves'

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
    'click .selectShelf': 'selectShelf'
    'click .toggleShelvesExpand': 'toggleShelvesExpand'

  serializeData: -> @model.serializeData()

  onShow: ->
    @showShelves()

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

  _showTransactions: ->
    @transactionsRegion.show new ItemTransactions { collection: @transactions }

  showShelves: ->
    @getShelves()
    .then (shelves) =>
      @shelves = new Shelves shelves, { selected: @model.get('shelves') }
    .then @ifViewIsIntact('_showShelves')
    .catch _.Error('showShelves err')

  getShelves: ->
    if @model.mainUserIsOwner
      return getShelvesByOwner app.user.id
    else
      itemShelves = @model.get 'shelves'
      unless itemShelves?.length > 0 then return Promise.resolve []
      return getShelvesByIds itemShelves
      .then _.values

  _showShelves: ->
    if @shelves.length is 0
      @ui.shelvesPanel.hide()
      return

    @shelvesSelector.show new ItemShelves
      collection: @shelves
      item: @model
      mainUserIsOwner: @model.mainUserIsOwner

  selectShelf: (e)->
    shelfId = e.currentTarget.href.split('/').slice(-1)[0]
    app.execute 'show:shelf', shelfId

  updateShelves: ->
    if @model.mainUserIsOwner
      if @shelves.length > @model.get('shelves').length
        @ui.toggleShelvesExpand.show()
      else
        @ui.toggleShelvesExpand.hide()

  afterDestroy: ->
    app.execute 'show:inventory:main:user'

  toggleShelvesExpand: -> @$el.find('.shelvesPanel').toggleClass 'expanded'
