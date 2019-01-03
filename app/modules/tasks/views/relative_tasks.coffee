RelativeTask = Marionette.ItemView.extend
  tagName: 'a'
  className: ->
    classes = 'relative-task'
    # if @model.get('hasEncyclopediaOccurence') then classes += ' good-candidate'
    if @model.get('globalScore') > 10 then classes += ' good-candidate'
    return classes

  attributes: ->
    href: @model.get 'pathname'
    'data-task-id': @model.id

  template: require './templates/relative_task'
  initialize: ->
    @lazyRender = _.LazyRender @

    @model.grabAuthors()
    .then @lazyRender

  serializeData: -> @model.serializeData()

  events:
    'click': 'select'

  select: (e)->
    unless _.isOpenedOutside e
      app.execute 'show:task', @model
      e.preventDefault()

module.exports = Marionette.CollectionView.extend
  className: 'inner-relative-tasks'
  childView: RelativeTask
  initialize: ->
    @currentTaskModelId = @options.currentTaskModel.id

  filter: (child)-> child.id isnt @currentTaskModelId
