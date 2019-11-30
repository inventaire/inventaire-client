module.exports = Marionette.CollectionView.extend
  className: 'groupsList'
  tagName: 'ul'
  getChildView: ->
    switch @options.mode
      when 'board' then require './group_board'
      when 'preview' then require './group_board_header'
      else require './group_li'
  emptyView: require './no_group'
  emptyViewOptions: ->
    message: @options?.emptyViewMessage or "you aren't in any group yet"
