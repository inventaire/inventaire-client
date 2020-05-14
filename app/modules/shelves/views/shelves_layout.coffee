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
    'click #hideShelves': 'hideShelves'
    'click #showShelves': 'showShelves'

  serializeData: ->
    inventoryUsername = @options.username
    currentUserName = app.user.get('username')
    if inventoryUsername is currentUserName
      editable: true

  ui:
    shelvesList: '#shelvesList'
    addShelf: '#addShelf'
    hideShelves: '#hideShelves'
    showShelves: '#showShelves'

  onShow: ->
    { username } = @options
    getUserId username
    .then getShelvesByOwner
    .then @showFromModel.bind(@)
    .catch app.Execute('show:error')
    @ui.showShelves.hide()

  hideShelves: ->
    @ui.shelvesList.hide()
    @ui.addShelf.hide()
    @ui.showShelves.show()
    @ui.hideShelves.hide()

  showShelves: ->
    @ui.shelvesList.show()
    @ui.addShelf.show()
    @ui.hideShelves.show()
    @ui.showShelves.hide()

  showFromModel: (docs)->
    unless docs.length > 0 then return
    @collection = new Shelves docs
    @shelvesList.show new ShelvesList { @collection }

  showNewShelfEditor: ()->
    app.layout.modal.show new NewShelfEditor { @collection }

getUserId = (username) ->
  unless username then return Promise.resolve app.user.id
  app.request 'get:userId:from:username', username
