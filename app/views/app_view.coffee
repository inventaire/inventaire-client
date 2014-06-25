Router = require "router"
Item = require "models/item"
Items = require "collections/items"
ItemList = require "views/item_list"
ItemForm = require "views/item_form"
AppTemplate = require "views/templates/app"
ColumnsTemplate = require "views/templates/columns"
idGenerator = require "lib/id_generator"


module.exports = AppView = Backbone.View.extend
  el: 'body'
  template: AppTemplate
  events:
    # LOGIN
    'click #login': 'login'
    'click #logout': 'logout'

    # TABS
    'click #personalInventory': 'filterByInventoryType'
    'click #networkInventories': 'filterByInventoryType'
    'click #publicInventories': 'filterByInventoryType'

    # VIEW MODE
    'click #listView': 'renderListView'
    'click #gridView': 'renderGridView'

    # FILTER
    'keyup #searchfield': 'searchItems'
    'click #noVisibilityFilter': 'updateVisibilityTabs'
    'click #private': 'updateVisibilityTabs'
    'click #contacts': 'updateVisibilityTabs'
    'click #public': 'updateVisibilityTabs'

    #ITEM FORM
    'click #addItem': 'revealItemForm'
    'click #validateNewItemForm' : 'validateNewItemForm'
    'click #cancelAddItem' : 'cancelAddItem'

    # OTHER EVENTS
    'click #clear-localStorage': 'clearLocalStorage'
    'click #hello': 'helloTest'
    'hello': 'helloTest'

  initialize: ->
    # window.router = @router = new Router
    # Backbone.history.start({pushState: true})

    @initilizePersonaLogin()
    @renderAppLayout()
    @initializeUserState()

    window.items = @items = new Items
    window.filteredItems = @filteredItems = new FilteredCollection @items
    @filterInventoryBy 'personalInventory'

    @items.on 'reset', @refresh, @
    @items.fetch {reset: true}


  renderAppLayout: ->
    $(@el).html @template
    return @

  ############ LOGIN ###########
  initilizePersonaLogin: ->
    if navigator.id?
      @email = $.cookie('email') || null
      navigator.id.watch
        onlogin: (assertion) ->
          console.log "login!!!!!!"
          $.post "/auth/login",
            assertion: assertion
          ,
          (data) ->
            console.log data
            window.location.reload()
        onlogout: ()->
          console.log "onlogout event not working usually!! how did you arrived here?!?"
    else
      console.log 'Persona Login not available: you might be offline'

  login: ->
    # loginModal = new LoginModal
    # loginModal.render()

    navigator.id.request()
    # console.log "login button"

  logout: ->
    # navigator.id.logout()
    $.post("/auth/logout",
      (data)->
        console.log "You have been logged out"
        window.location.reload()
      )

  initializeUserState: ->
    if @email
      console.log 'logged!'
      $('#login').hide()
      $('#logout').show()
    else
      console.log 'not logged!'
      $('#login').show()
      $('#logout').hide()


  ############### VIEW MODE #############
  renderListView: ->
    $('.viewmode').removeClass('active')
    $('#listView').parent().addClass('active')
    console.log @filteredItems
    window.fi = @filteredItems
    list = new ItemList @filteredItems

  renderGridView: ->
    $('.viewmode').removeClass('active')
    $('#gridView').parent().addClass('active')
    grid = new Backgrid.Grid
      columns: ColumnsTemplate
      collection: @items
    $("#itemsView").html(grid.render().el)
    return @

  ############# FILTER MODE #############

  searchItems: (text)->
    @textFilter $('#searchfield').val()

  textFilter: (text)->
    if text.length != 0
      filterExpr = new RegExp text, "i"
      @filteredItems.filterBy 'text', (model)->
        return model.matches filterExpr
    else
      @filteredItems.removeFilter 'text'
    @refresh()

  refresh: ->
    @renderListView()
    if filteredItems.length is 0
      $('#itemsView').append('<li class="text-center hidden">No item here</li>').find('li').fadeIn()

    if @filteredItems.hasFilter 'personalInventory'
      $('#visibility-tabs').show()
    else
      @setVisibilityFilter null
      $('#visibility-tabs').hide()

  ######### VISIBILITY FILTER #########
  updateVisibilityTabs: (e)->
    visibility = $(e.currentTarget).attr('id')
    if visibility is 'noVisibilityFilter'
      @setVisibilityFilter null
    else
      @setVisibilityFilter visibility
    @refresh()

    $('#visibility-tabs li').removeClass('active')
    $(e.currentTarget).find('li').addClass('active')

  visibilityFilters:
    'private': {'visibility':'private'}
    'contacts': {'visibility':'contacts'}
    'public': {'visibility':'public'}

  setVisibilityFilter: (audience)->
    otherFilters = _.without _.keys(@visibilityFilters), audience
    otherFilters.forEach (otherFilterName)->
      @filteredItems.removeFilter otherFilterName
    if audience?
      @filteredItems.filterBy audience, @visibilityFilters[audience]

  ############# ITEM FORM ###############

  revealItemForm: (e)->
    e.preventDefault()
    form = new ItemForm
    form.render()
    $('#addItem').fadeOut()
    form.$el.fadeIn()

  validateNewItemForm: (e)->
    newItem =
      _id: idGenerator(6)
      title: $('#title').val()
      visibility: $('#visibility').val()
      transactionMode: $('#transactionMode').val()
      comment: $('#comment').val()
      tags: $('#tags').val()
      owner: "username"
      created: new Date()

    $('#title').val('')
    $('#comment').val('')
    $('#item-form').fadeOut().html('')
    $('#addItem').fadeIn()

    console.log "newItem:"
    console.dir newItem

    @items.add newItem
    # @items.create newItem

  cancelAddItem: ->
    $('#item-form').html('')
    $('#addItem').fadeIn()

  ####################################

  clearLocalStorage: (e)->
    e.preventDefault()
    localStorage.clear()
    console.log "LocalStorage Cleared! Reload the page to see the emptied localStorage effect or implement a namespace so that I can reset the collection from here!!!"


  helloTest: (e)->
    e.preventDefault()
    console.log 'hellloooooooooooooooo'
    $.get('/hello').then (data)-> console.log data

  ############ TABS ############
  filterByInventoryType: (e)->
    inventoryType = $(e.currentTarget).attr('id')
    console.log inventoryType
    @filterInventoryBy inventoryType
    @refresh()
    @updateInventoriesTabs e

  updateInventoriesTabs: (e)->
    $('#inventoriesTabs').find('.active').removeClass('active')
    $(e.currentTarget).parent().addClass('active')

  inventoryFilters:
    'personalInventory': {'owner':'username'}
    'networkInventories': {'owner':'zombo'}
    'publicInventories': {'owner':'notUsername'}

  filterInventoryBy: (filterName)->
    otherFilters = _.without _.keys(@inventoryFilters), filterName
    otherFilters.forEach (otherFilterName)->
      @filteredItems.removeFilter otherFilterName
    @filteredItems.filterBy filterName, @inventoryFilters[filterName]