ContactTemplate = require "views/templates/contact-template"
console.dir ContactTemplate

module.exports = ContactView = Backbone.View.extend(
  tagName: "div"
  className: "contact"
  template: ContactTemplate
  events:
    "click .remove-contact": "destroy"
    "keyup input": "update"

  initialize: ->
    @listenTo @model, "destroy", @remove
    return

  render: (arg, args) ->
    @$el.html @template(@model.attributes)
    this

  update: (ev) ->
    $elem = $(ev.target)
    attribute = $elem.attr("class").replace("contact-", "")
    update = {}
    update[attribute] = $elem.val()
    @model.save update
    return

  destroy: ->
    @model.destroy()
    return
)