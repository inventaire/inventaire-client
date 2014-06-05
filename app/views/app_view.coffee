AppTemplate = require "views/templates/app"
Items = require "collections/items"
Item = require "models/item"
columns = require "views/templates/columns"
idGenerator = require "lib/id_generator"


module.exports = AppView = Backbone.View.extend
  el: 'body'
  template: AppTemplate
  events:
    'click #clear-localStorage': 'clearLocalStorage'
    'click #addItem': 'revealItemForm'
    'click #validateNewItemForm' : 'validateNewItemForm'

    # TABS
    'click #allItems': 'allItemsFilter'
    'click #personalInventory': 'personalInventoryFilter'
    'click #networkInventories': 'networkInventoriesFilter'
    'click #publicInventories': 'publicInventoriesFilter'

    # VIEW MODE
    'click #listView': 'renderlistView'
    'click #gridView': 'renderGridView'

  initialize: ->
    @items = new Items
    # @items.fetch {reset: true}
    @render()

  render: ->
    $(@el).html(@template())
    @items.fetch()
    window.items = @items
    return @



  # TABS
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


  renderlistView: ->
    $('.viewmode').removeClass('active')
    $('#listView').parent().addClass('active')
    # list = new listView
    console.log "TO BE IMPLEMENTED"


  renderGridView: ->
    $('.viewmode').removeClass('active')
    $('#gridView').parent().addClass('active')
    grid = new Backgrid.Grid
      columns: columns
      collection: @items
    $("#item-list").html(grid.render().el);
    return @


  revealItemForm: (e)->
    e.preventDefault()
    $('#addItem').fadeOut()
    $('#item-form').fadeIn()


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
    $('#item-form').fadeOut()
    $('#addItem').fadeIn()

    console.log "VALIDATE!"

  clearLocalStorage: (e)->
    e.preventDefault()
    localStorage.clear()
    console.log "LocalStorage Cleared! Reload the page to see the emptied localStorage effect or implement a namespace so that I can reset the collection from here!!!"