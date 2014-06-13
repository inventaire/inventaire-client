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
    'click #allItems': 'allItemsFilter'
    'click #personalInventory': 'personalInventoryFilter'
    'click #networkInventories': 'networkInventoriesFilter'
    'click #publicInventories': 'publicInventoriesFilter'

    # VIEW MODE
    'click #listView': 'renderListView'
    'click #gridView': 'renderGridView'

    # FILTER
    'keyup #searchfield': 'searchItems'

    #ITEM FORM
    'click #addItem': 'revealItemForm'
    'click #validateNewItemForm' : 'validateNewItemForm'
    'click #cancelAddItem' : 'cancelAddItem'

    # OTHER EVENTS
    'click #clear-localStorage': 'clearLocalStorage'

  initialize: ->
    @initilizePersonaLogin()
    @items = new Items
    @items.fetch {reset: true}
    window.items = @items
    window.app = @
    @render()
    @renderListView()
    @initializeUserState()

  render: ->
    $(@el).html(@template())
    return @

  ############ LOGIN ###########
  initilizePersonaLogin: ->
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

  login: ->
    console.log('trying to loggin!')
    # loginModal = new LoginModal
    # loginModal.render()

    # navigator.id.request()
    # console.log "login button"

  logout: ->
    # navigator.id.logout()
    $.post("/auth/logout",
      (data)->
        console.log "You have been logged out"
        window.location.reload()
      )

  initializeUserState: ->
    console.log 'userstate!'
    if @email
      console.log 'logged!'
      $('#login').hide()
      $('#logout').show()
    else
      console.log 'not logged!'
      $('#login').show()
      $('#logout').hide()

  ############ TABS ############
  allItemsFilter: ->
    $('.tabs').children().removeClass('active')
    $('#allItems').parent().addClass('active')
    console.log "hello allItems!! [filter to be implemented]"

  personalInventoryFilter: ->
    $('.tabs').children().removeClass('active')
    $('#personalInventory').parent().addClass('active')
    console.log "hello personalInventory!! [filter to be implemented]"

  networkInventoriesFilter: ->
    $('.tabs').children().removeClass('active')
    $('#networkInventories').parent().addClass('active')
    console.log "hello networkInventories!! [filter to be implemented]"

  publicInventoriesFilter: ->
    $('.tabs').children().removeClass('active')
    $('#publicInventories').parent().addClass('active')
    console.log "hello publicInventories!! [filter to be implemented]"


  ############### VIEW MODE #############
  renderListView: ->
    $('.viewmode').removeClass('active')
    $('#listView').parent().addClass('active')
    list = new ItemList @items

  renderGridView: ->
    $('.viewmode').removeClass('active')
    $('#gridView').parent().addClass('active')
    grid = new Backgrid.Grid
      columns: ColumnsTemplate
      collection: @items
    $("#itemsView").html(grid.render().el);
    return @

  ############# FILTER MODE #############

  searchItems: (text)->
    @filter $('#searchfield').val()

  filter: (text)->
    if text.length != 0
      @items.filterExpr = new RegExp text, "i"
    else
      @items.filterExpr = null
    @refresh()

  refresh: ->
    # @items.sort()
    @renderListView()

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

    console.log "app_view:validateNewItemForm"
    console.log "newItem"
    console.dir newItem

    @items.create newItem

  cancelAddItem: ->
    $('#item-form').html('')
    $('#addItem').fadeIn()

  ####################################

  clearLocalStorage: (e)->
    e.preventDefault()
    localStorage.clear()
    console.log "LocalStorage Cleared! Reload the page to see the emptied localStorage effect or implement a namespace so that I can reset the collection from here!!!"