Shelves = require '../collections/shelves'
{ getShelvesByOwner } = require 'modules/shelves/lib/shelf'
NewShelfEditor = require './new_shelf_editor'
ShelvesList = require './shelves_list'

module.exports = Marionette.LayoutView.extend
  template: require './templates/shelves_layout'

  regions:
    shelvesList: '#shelvesList'

  behaviors:
    BackupForm: {}

  events:
    'click #addShelf': 'showNewShelfEditor'

  serializeData: ->
    inventoryUsername = @options.username
    currentUserName = app.user.get('username')
    if inventoryUsername is currentUserName
      editable: true

  onShow: ->
    { username } = @options
    getUserId username
    .then getShelvesByOwner
    .then @showFromModel.bind(@)
    .catch app.Execute('show:error')

  showFromModel: (models)->
    unless models.length > 0 then return
    @collection = new Shelves models
    @shelvesList.show new ShelvesList { @collection }

  showNewShelfEditor: ()->
    app.layout.modal.show new NewShelfEditor { @collection }

getUserId = (username) ->
  unless username then return Promise.resolve app.user.id
  app.request 'get:userId:from:username', username
