module.exports = NoItem = Backbone.Marionette.ItemView.extend
  tagName: "div"
  className: "text-center hidden"
  template: require './templates/no_item'
  onShow: -> @$el.fadeIn()