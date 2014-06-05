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
    'click #listView': 'renderlistView'
    'click #gridView': 'renderGridView'

    #ITEM FORM
    'click #addItem': 'revealItemForm'
    'click #validateNewItemForm' : 'validateNewItemForm'

  initialize: ->
    @items = new Items
    @items.fetch {reset: true}
    @render()

  render: ->
    $(@el).html(@template())
    window.items = @items
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


  ############### VIEW MODE ############
  renderlistView: ->
    $('.viewmode').removeClass('active')
    $('#listView').parent().addClass('active')
    list = new ItemList @items
    console.dir list
    # $("#item-list").html(list.render().el);

  renderGridView: ->
    $('.viewmode').removeClass('active')
    $('#gridView').parent().addClass('active')
    grid = new Backgrid.Grid
      columns: ColumnsTemplate
      collection: @items
    $("#item-list").html(grid.render().el);
    return @

  ############# ITEM FORM ###############

  revealItemForm: (e)->
    e.preventDefault()
    form = new ItemForm
    form.render()
    $('#addItem').fadeOut()
    form.$el.fadeIn()


  validateNewItemForm: (e)->
    newItem =
      title: $('#title').val()
      comment: $('#comment').val()
      created: new Date()
      owner: "username"

    console.log newItem

    @items.create newItem

    $('#title').val('')
    $('#comment').val('')
    $('#item-form').fadeOut().html('')
    $('#addItem').fadeIn()

    console.log "VALIDATE!"

  ####################################

  clearLocalStorage: (e)->
    e.preventDefault()
    localStorage.clear()
    console.log "LocalStorage Cleared! Reload the page to see the emptied localStorage effect or implement a namespace so that I can reset the collection from here!!!"