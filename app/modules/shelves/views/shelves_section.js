Shelves = require '../collections/shelves'
{ getShelvesByOwner } = require 'modules/shelves/lib/shelves'
ShelvesList = require './shelves_list'

module.exports = Marionette.LayoutView.extend
  template: require './templates/shelves_section'

  regions:
    shelvesList: '#shelvesList'

  behaviors:
    BackupForm: {}

  events:
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
    hideShelves: '#hideShelves'
    showShelves: '#showShelves'
    toggleButtons: '#toggleButtons'

  onShow: ->
    { username } = @options

    @waitForList = getUserId username
      .then getShelvesByOwner
      .then @ifViewIsIntact('showFromModel')
      .catch app.Execute('show:error')

    @ui.showShelves.hide()

  hideShelves: (e)->
    @ui.shelvesList.addClass 'wrapped'
    @ui.showShelves.show()
    @ui.hideShelves.hide()
    e.stopPropagation()
    @_shelvesShown = false

  showShelves: (e)->
    @ui.shelvesList.removeClass 'wrapped'
    @ui.hideShelves.show()
    @ui.showShelves.hide()
    e.stopPropagation()
    @_shelvesShown = true

  toggleShelves: (e)->
    if @_shelvesShown then @hideShelves(e)
    else @showShelves(e)

  showFromModel: (docs)->
    if docs && docs.length < 1 then return
    @collection = new Shelves docs
    @shelvesList.show new ShelvesList { @collection }
    if @collection.length > 5 then @ui.toggleButtons.removeClass 'hidden'

getUserId = (username)->
  unless username then return Promise.resolve app.user.id
  app.request 'get:userId:from:username', username
