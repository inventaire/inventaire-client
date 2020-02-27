Shelves = require '../collections/shelves'
ShelfModel = require '../models/shelf'
ShelvesView = require './shelves_list'
error_ = require 'lib/error'
getActionKey = require 'lib/get_action_key'
{ listingsData } = require 'modules/inventory/lib/item_creation'

module.exports = Marionette.LayoutView.extend
  template: require './templates/shelves_layout'
  regions:
    shelves: '.shelves'

  behaviors:
    BackupForm: {}

  initialize: ->
    @listingData = listingsData()['private']

  events:
    'click .shelfLiInfo': 'showShelf'
    'click #addShelf': 'showNewShelfEditor'
    'click a.cancelShelfEdition': 'hideNewShelfEditor'
    'keydown .shelfEditor': 'shelfEditorKeyAction'
    'click a#createShelf': 'createShelf'
    'click .listingChoice': 'updateListing'

  serializeData: ->
    listingsData: listingsData()
    #Default listing for a new shelf
    listingData: @listingData
    _id: 'newShelf'

  onShow: ->
    { username } = @options
    getUserId username
    .then getByOwner
    .then @showFromModel.bind(@)
    .catch app.Execute('show:error')

  updateListing: (e)->
    if e.currentTarget? then { id: listing } = e.currentTarget
    @listingData = listingsData()[listing]
    @render()
    @showNewShelfEditor()

  showShelf: (e)->
    { id:shelf } = e.currentTarget
    app.execute 'show:shelf', shelf

  showFromModel: (models)->
    @collection = new Shelves models
    @shelves.show new ShelvesView { @collection }

  showNewShelfEditor: (e)->
    $("#addShelf").hide()
    # Wrapper necessary to "display: none"
    # separately from "display: flex" of the editor
    $("#newShelfEditorWrapper").show().find('textarea').focus()
    e?.stopPropagation()

  hideNewShelfEditor: (e)->
    $("#newShelfEditorWrapper").hide()
    $("#addShelf").show()
    e?.stopPropagation()

  shelfEditorKeyAction: (e)->
    key = getActionKey e
    if key is 'esc'
      @hideNewShelfEditor()
      e.stopPropagation()
    else if key is 'enter' and e.ctrlKey
      @createShelf()
      e.stopPropagation()

  createShelf: ->
    @hideNewShelfEditor()
    name = $("#newName").val()
    description = $("#newDesc").val()
    if !name && !description then return
    _.preq.post app.API.shelves.create, { name, description, listing: @listingData.id }
    .get('shelf')
    .then (newShelf)=>
      newShelfModel = new ShelfModel newShelf
      @collection.add newShelfModel
      $("#newName").val('')
      $("#newDesc").val('')
    .catch _.Error('shelf creation error')

getUserId = (username) ->
  unless username then return Promise.resolve app.user.id
  app.request 'get:userId:from:username', username

getByOwner = (userId) ->
  _.preq.get app.API.shelves.byOwners userId
  .get 'shelves'
  .then (shelves)-> Object.values(shelves)
