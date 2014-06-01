module.exports = ItemView = Backbone.View.extend(
  events:
    click: "select"

  tagName: "li"
  initialize: ->
    @listenTo @model, "change", @render
    @listenTo @model, "destroy", @remove
    return

  render: ->
    @$el.html @model.fullName()
    this

  select: ->
    @trigger "select", @model
    return
)
