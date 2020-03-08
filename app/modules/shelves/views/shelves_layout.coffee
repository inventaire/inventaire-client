Shelves = require '../collections/shelves'
NewShelfEditor = require './new_shelf_editor'

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
    $('#addShelf').hide()
    $('#newShelfEditorWrapper').show()
    app.layout.modal.show new NewShelfEditor { @collection }

  closeShelvesList: ->
    $('.shelvesWrapper').hide()

getUserId = (username) ->
  unless username then return Promise.resolve app.user.id
  app.request 'get:userId:from:username', username

getByOwner = (userId) ->
  _.preq.get app.API.shelves.byOwners userId
  .get 'shelves'
  .then (shelves)-> Object.values(shelves)
