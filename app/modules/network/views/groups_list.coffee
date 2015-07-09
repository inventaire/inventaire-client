module.exports = Marionette.CollectionView.extend
  className: 'groupsList'
  tagName: 'ul'
  getChildView: ->
    if @options.showBoards then require './group_board'
    else require './group'
  emptyView: require './no_group'
  emptyViewOptions: ->
    message: @options?.emptyViewMessage or "you aren't in any group yet"
