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

  initialize: ->
    @items = new Items
    # @items.fetch {reset: true}
    @render()

  render: ->
    $(@el).html(@template())
    grid = new Backgrid.Grid
      columns: columns
      collection: @items

    $("#item-list").append(grid.render().el);

    @items.fetch()
    # @items.on 'change', (event)-> console.log "changing!" && console.log event
    # @items.on 'add', (event)-> console.log event

    # @items.create
    #   id: idGenerator(6)
    #   title: "hello Grid!"

    window.items = @items

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