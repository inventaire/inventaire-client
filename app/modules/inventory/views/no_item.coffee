module.exports = class NoItem extends Backbone.Marionette.ItemView
  tagName: "div"
  className: "text-center hidden"
  template: require './templates/no_item'
  onShow: -> @$el.fadeIn()