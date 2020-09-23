module.exports = Marionette.CollectionView.extend
  tagName: 'ul'
  className: 'usersList'
  childView: require './user_li'
  childViewOptions: ->
    groupContext: @options.groupContext
    group: @options.group
    showEmail: @options.showEmail
    stretch: @options.stretch
  emptyView: require './no_user'
  emptyViewOptions: ->
    message: @options.emptyViewMessage
    link: @options.emptyViewLink
    showEmail: @options.showEmail

  initialize: ->
    { filter, textFilter } = @options
    if filter? then @filter = filter

    if textFilter
      @on 'filter:text', @setTextFilter.bind(@)

  setTextFilter: (text)->
    @filter = (model)-> model.matches text
    @render()
