Shelves = require '../collections/shelves'
{ getShelvesByOwner } = require 'modules/shelves/lib/shelf'
NewShelfEditor = require './new_shelf_editor'
ShelvesList = require './shelves_list'

module.exports = Marionette.LayoutView.extend
  template: require './templates/shelves_section'

  regions:
    shelvesList: '#shelvesList'

  behaviors:
    BackupForm: {}

  events:
    'click #addShelf': 'showNewShelfEditor'
    'click #hideShelves': 'hideShelves'
    'click #showShelves': 'showShelves'
    'click #shelvesHeader': 'toggleShelves'

  initialize: ->
    @_shelvesShown = true

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

    @waitForList = getUserId username
      .then getShelvesByOwner
      .then @ifViewIsIntact('showFromModel')
      .catch app.Execute('show:error')

    @ui.showShelves.hide()

  hideShelves: (e)->
    @ui.shelvesList.hide()
    @ui.addShelf.hide()
    @ui.showShelves.show()
    @ui.hideShelves.hide()
    e.stopPropagation()
    @_shelvesShown = false

  showShelves: (e)->
    @ui.shelvesList.show()
    @ui.addShelf.show()
    @ui.hideShelves.show()
    @ui.showShelves.hide()
    e.stopPropagation()
    @_shelvesShown = true

  toggleShelves: (e)->
    if @_shelvesShown then @hideShelves(e)
    else @showShelves(e)

  showFromModel: (docs)->
    unless docs.length > 0 then return
    @collection = new Shelves docs
    @shelvesList.show new ShelvesList { @collection }

  showNewShelfEditor: (e)->
    app.layout.modal.show new NewShelfEditor { @collection }
    e.stopPropagation()

getUserId = (username) ->
  unless username then return Promise.resolve app.user.id
  app.request 'get:userId:from:username', username
