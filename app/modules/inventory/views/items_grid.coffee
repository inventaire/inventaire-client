module.exports = Backbone.Marionette.CompositeView.extend
  className: 'itemsGrid'
  template: require './templates/items_grid'
  childViewContainer: 'tbody'
  childView: require './item_row'
  emptyView: require './no_item'
  # ui:
  #   filter: 'input.filter'

  # initialize: ->
  #   @lazyRender = _.debounce @render.bind(@), 300
  #   _.inspect(@)

#   filterRows: ->
#     text = @ui.filter.val()
#     console.log 'filter', text
#     @filter = Filter(text)
#     @_renderChildren()


# Filter = (text)->
#   if text?.length > 0
#     return filter = (child, index, collection)-> child.matches text
#   else return null
