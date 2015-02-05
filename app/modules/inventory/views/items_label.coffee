module.exports = Backbone.Marionette.ItemView.extend
  template: require './templates/items_label'
  className: 'itemsLabel'
  serializeData: ->
    label: _.i18n 'last books added'
