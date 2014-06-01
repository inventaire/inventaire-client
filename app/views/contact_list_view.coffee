ItemView = require "./item_view"

module.exports = ContactListView = Backbone.View.extend(
  el: "#contact-list"
  initialize: (collection) ->
    @collection = collection
    @listenTo @collection, "add", @addOne
    @listenTo @collection, "change:firstName", @refresh
    @listenTo @collection, "reset", @addAll
    @collection.fetch reset: true
    return

  refresh: ->
    @collection.sort()
    @$el.html ""
    @addAll()
    return

  addOne: (contact) ->
    item = new ItemView(model: contact)
    @listenTo item, "select", @selectContact
    @$el.append item.render().el
    return

  addAll: ->
    _.each @collection.filtered(@filterExpr), ((contact) ->
      @addOne contact
      return
    ), this
    return

  selectContact: (contact) ->
    @trigger "select", contact
    return

  filter: (text) ->
    unless text.length is 0
      @filterExpr = new RegExp(text, "i")
    else
      @filterExpr = null
    @refresh()
    return

  filterExpr: null
)
