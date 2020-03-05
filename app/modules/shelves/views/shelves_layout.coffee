Shelves = require '../collections/shelves'
ShelfModel = require '../models/shelf'
ShelvesView = require './shelves_list'
NewShelfEditor = require './new_shelf_editor'
error_ = require 'lib/error'
getActionKey = require 'lib/get_action_key'
{ listingsData } = require 'modules/inventory/lib/item_creation'

module.exports = Marionette.LayoutView.extend
  template: require './templates/shelves_layout'
  regions:
    shelves: '.shelves'
    newShelfEditorWrapper: '#newShelfEditorWrapper'

  behaviors:
    BackupForm: {}

  events:
    'click #addShelf': 'showNewShelfEditor'
    'click #closeShelves': 'closeShelvesList'

  onShow: ->
    { username } = @options
    getUserId username
    .then getByOwner
    .then @showFromModel.bind(@)
    .catch app.Execute('show:error')

  showFromModel: (models)->
    @collection = new Shelves models
    @shelves.show new ShelvesView { @collection }

  showNewShelfEditor: (e)->
    $("#addShelf").hide()
    @newShelfEditorWrapper.show new NewShelfEditor { @collection }
    e?.stopPropagation()

  closeShelvesList: ->
    $('.shelvesWrapper').hide()

getUserId = (username) ->
  unless username then return Promise.resolve app.user.id
  app.request 'get:userId:from:username', username

getByOwner = (userId) ->
  _.preq.get app.API.shelves.byOwners userId
  .get 'shelves'
  .then (shelves)-> Object.values(shelves)
