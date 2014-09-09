module.exports = class CategoryMenu extends Backbone.Marionette.ItemView
  template: require 'views/items/form/templates/category_menu'
  serializeData: -> return @model
  events:
    'click .category': (e)->
      @updateSearchUrlByCategory(e)
      @toggleActive(e)

  updateSearchUrlByCategory: (e)->
    _.updateQuery {category: e.currentTarget.id}

  toggleActive: (e)->
    $('.category').addClass('grey')
    $(e.currentTarget).removeClass('grey')
