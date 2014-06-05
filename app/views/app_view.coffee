Item = require "models/item"
Items = require "collections/items"
ItemList = require "views/item_list"
ItemForm = require "views/item_form"
ColumnsTemplate = require "views/templates/columns"
AppTemplate = require "views/templates/app"
idGenerator = require "lib/id_generator"


module.exports = AppView = Backbone.View.extend
  el: 'body'
  template: AppTemplate
  events:
    'click #clear-localStorage': 'clearLocalStorage'

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

  initialize: ->
    @items = new Items
    @items.fetch {reset: true}
    window.items = @items
    window.app = @
    @render()
    @renderListView()

  render: ->
    $(@el).html(@template())
    return @

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
    console.log "filterExpr"
    console.log @items.filterExpr
    @refresh()

  refresh: ->
    # @items.sort()
    $('#itemsView').html ""
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
      id: idGenerator(6)
      title: $('#title').val()
      comment: $('#comment').val()
      tags: $('#tags').val()
      owner: "username"
      created: new Date()

    @items.create newItem

    $('#title').val('')
    $('#comment').val('')
    $('#item-form').fadeOut().html('')
    $('#addItem').fadeIn()

    console.log "app_view:validateNewItemForm"
    console.log "newItem"
    console.dir newItem

  ####################################

  clearLocalStorage: (e)->
    e.preventDefault()
    localStorage.clear()
    console.log "LocalStorage Cleared! Reload the page to see the emptied localStorage effect or implement a namespace so that I can reset the collection from here!!!"