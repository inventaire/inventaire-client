Shelves = require '../collections/shelves'
ShelfModel = require '../models/shelf'
ShelvesView = require './shelves_list'
error_ = require 'lib/error'
getActionKey = require 'lib/get_action_key'
{ listingsData } = require 'modules/inventory/lib/item_creation'
{ promisify } = require 'util'

module.exports = Marionette.LayoutView.extend
  id: 'shelvesLayout'
  template: require './templates/shelves_layout'
  regions:
    shelves: '.shelves'

  events:
    'click .shelfLiInfo': 'showShelf'
    'click #addShelf': 'showNewShelfEditor'
    'click a.cancelShelfEdition': 'hideNewShelfEditor'
    'keydown .shelfEditor': 'shelfEditorKeyAction'
    'click a#validateShelf': 'createShelf'
    'click li.listing': 'updateShelfVisibility'

  serializeData: ->
      listings: listingsData()
      icon: 'globe'

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
    collection = new Backbone.Collection models
    @shelves.show new ShelvesView { collection }

  showNewShelfEditor: (e)->
    $("#addShelf").hide()
    # Wrapper necessary to "display: none"
    # separatly from "display: flex" the editor
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
    name = $(".shelfName").val()
    description = $(".shelfDesc").val()
    if !name && !description then return
    listing = 'private'
    _.preq.post app.API.shelves.create, { name, description, listing }
    .catch _.Error('shelf creation error')

getUserId = (username) ->
  unless username then return Promise.resolve app.user.id
  app.request 'get:userId:from:username', username

getByOwner = (userId) ->
  _.preq.get app.API.shelves.byOwners userId
  .get 'shelves'
  .then (shelves)->
    shelf = Object.values(shelves).map (shelf)->
      if shelf? then new ShelfModel shelf
      else throw error_.new 'not found', 404, { id }
