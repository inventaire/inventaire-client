RelativeTask = Marionette.ItemView.extend
  className: ->
    classes = 'relative-task'
    # if @model.get('hasEncyclopediaOccurence') then classes += ' good-candidate'
    if @model.get('globalScore') > 10 then classes += ' good-candidate'
    return classes

  attributes: ->
    'data-task-id': @model.id

  template: require './templates/relative_task'
  initialize: ->
    @lazyRender = _.LazyRender @

    @model.waitForData?.then @lazyRender

  serializeData: -> @model.serializeData()

  events:
    'click': 'select'

  select: ->
    app.execute 'show:task', @model

module.exports = Marionette.CollectionView.extend
  className: 'inner-relative-tasks'
  childView: RelativeTask
  initialize: ->
    @currentTaskModelId = @options.currentTaskModel.id

  filter: (child)-> child.id isnt @currentTaskModelId
