module.exports = class NoItem extends Backbone.Marionette.ItemView
  tagName: "li"
  className: "text-center hidden"
  template: ->
    if app.data.ready
      require 'views/items/templates/no_item'
    else
      require 'views/templates/loading'
  onShow: -> @$el.fadeIn()