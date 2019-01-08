module.exports = Marionette.CompositeView.extend
  className: ->
    classes = 'entity-history'
    if @options.standalone then classes += ' standalone'
    return classes
  template: require './templates/history'
  childViewContainer: '.inner-history'
  childView: require './version'
  initialize: ->
    { @model } = @options
    if @model then @collection = @model.history

  serializeData: ->
    attrs = @model?.toJSON() or {}
    _.extend attrs,
      standalone: @options.standalone
