module.exports = class NoItem extends Backbone.Marionette.ItemView
  tagName: "li"
  className: "text-center"
  template: require 'views/templates/no_item'