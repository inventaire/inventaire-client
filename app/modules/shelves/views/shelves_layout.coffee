Shelves = require '../collections/shelves'
NewShelfEditor = require './new_shelf_editor'
InventoryCommonNav = require 'modules/inventory/views/inventory_common_nav'

module.exports = InventoryCommonNav.extend
  template: require './templates/shelves_layout'

  behaviors:
    BackupForm: {}

  events:
    'click #addShelf': 'showNewShelfEditor'

  onShow: ->
    { username } = @options
    getUserId username
    .then getByOwner
    .tap addNewPlaceholder(username)
    .then @showFromModel.bind(@)
    .catch app.Execute('show:error')

  showFromModel: (models)->
    unless models.length > 0 then return
    @collection = new Shelves models
    @showList @shelvesList, @collection

  showNewShelfEditor: (e)->
    app.layout.modal.show new NewShelfEditor { @collection }

addNewPlaceholder = (username)-> (models)->
  # build a fake shelf model to pass to Shelves collection
  loggedInUsername = app.user.get('username')
  if loggedInUsername is username
    models.unshift placeholderModel

placeholderModel =
  newPlaceholder: true
  listing: 'private'
  _id: 'newPlaceholder'

getUserId = (username) ->
  unless username then return Promise.resolve app.user.id
  app.request 'get:userId:from:username', username

getByOwner = (userId) ->
  _.preq.get app.API.shelves.byOwners userId
  .get 'shelves'
  .then (shelves)-> Object.values(shelves)
