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
