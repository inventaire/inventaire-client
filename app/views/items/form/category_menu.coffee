module.exports = class CategoryMenu extends Backbone.Marionette.ItemView
  template: require 'views/items/form/templates/category_menu'
  serializeData: -> return @model