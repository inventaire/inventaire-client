module.exports = class NoItem extends Backbone.Marionette.ItemView
  tagName: "li"
  className: "text-center hidden"
  template: require 'views/templates/no_item'
  onShow: -> @$el.fadeIn()