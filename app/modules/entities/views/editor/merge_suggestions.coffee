module.exports = Marionette.CompositeView.extend
  template: require './templates/merge_suggestions'
  className: ->
    className = 'outer-merge-suggestions'
    if @options.standalone then className += ' standalone'
    return className
  childViewContainer: '.inner-merge-suggestions'
  childView: require './merge_suggestion'
  childViewOptions: ->
    toEntity: @model
  emptyView: require 'modules/search/views/no_result'
  serializeData: ->
    attrs = @model.toJSON()
    attrs.standalone = @options.standalone
    return attrs

  events:
    'click .selectAll': 'selectAll'
    'click .unselectAll': 'unselectAll'
    'click .mergeSelectedSuggestions': 'mergeSelectedSuggestions'

  selectAll: -> @setAllSelected true
  unselectAll: -> @setAllSelected false
  setAllSelected: (bool)->
    _.toArray @$el.find('input[type="checkbox"]')
    .forEach (el)-> el.checked = bool

  mergeSelectedSuggestions: ->
    selectedViews = Object.values(@children._views).filter (child)-> child.isSelected

    mergeSequentially = ->
      nextSelectedView = selectedViews.shift()
      unless nextSelectedView? then return
      nextSelectedView.merge()
      .then mergeSequentially

    # Merge 3 at a time
    mergeSequentially()
    mergeSequentially()
    mergeSequentially()
