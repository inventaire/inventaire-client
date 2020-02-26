{ listingsData: listingsDataFn } = require 'modules/inventory/lib/item_creation'
getActionKey = require 'lib/get_action_key'

module.exports = Marionette.LayoutView.extend
  class:'shelfLayout'
  template: require './templates/shelf'
  behaviors:
    BackupForm: {}

  initialize: ->
    @lazyRender = _.LazyRender @
    @listenTo @model, 'change', @render.bind(@)

  events:
    'click #showShelfEdit': 'showEditor'
    'click a.cancelShelfEdition': 'hideEditor'
    'click #validateShelf': 'updateShelf'
    'keydown #shelfEditor': 'shelfEditorKeyAction'
    'click .listingChoice': 'updateListing'

  serializeData: ->
    listing = @model.get('listing')
    listingsData = listingsDataFn()
    attrs = @model.toJSON()
    _.extend attrs,
      listingsData: listingsData
      listingData: listingsData[listing]
      editable: @isEditable()

  regions:
    shelf: '.shelf'

  updateListing: (e)->
    if e.currentTarget? then { id:listing } = e.currentTarget
    @model.set('listing', listing)
    @showEditor()

  isEditable: ->
    return @model.get('owner') is app.user.id

  showEditor: (e)->
    $("#infoBox").hide()
    $("#showShelfEdit").hide()
    $(".editorButtonsWrapper").show()
    $(".shelfEditorWrapper").show().find('textarea').focus()
    e?.stopPropagation()

  hideEditor: (e)->
    $("#showShelfEdit").show()
    $(".editorButtonsWrapper").hide()
    $(".shelfEditorWrapper").hide()
    $("#infoBox").show()
    e?.stopPropagation()

  updateShelf: (e)->
    shelfId = @model.get('_id')
    @hideEditor()
    name = $("#shelfNameEditor").val()
    description = $("#shelfDescEditor").val()
    listing = @model.get('listing')
    _.preq.post app.API.shelves.update, { shelf:shelfId, name, description, listing }
    .get 'shelf'
    .then (updatedShelf) => @model.set(updatedShelf)
    .catch _.Error('shelf update error')

  shelfEditorKeyAction: (e)->
    key = getActionKey e
    if key is 'esc'
      @hideEditor()
      e.stopPropagation()
    else if key is 'enter' and e.ctrlKey
      @updateShelf()
      e.stopPropagation()
