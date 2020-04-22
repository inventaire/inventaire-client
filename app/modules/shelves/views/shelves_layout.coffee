Shelves = require '../collections/shelves'
{ getShelvesByOwner } = require 'modules/shelves/lib/shelf'
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
    .then getShelvesByOwner
    .then @showFromModel.bind(@)
    .catch app.Execute('show:error')

  showFromModel: (models)->
    unless models.length > 0 then return
    @collection = new Shelves models
    @showList @shelvesList, @collection

  showNewShelfEditor: (e)->
    app.layout.modal.show new NewShelfEditor { @collection }

getUserId = (username) ->
  unless username then return Promise.resolve app.user.id
  app.request 'get:userId:from:username', username
