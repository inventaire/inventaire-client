entityItems = require '../lib/entity_items'

module.exports = Marionette.LayoutView.extend
  template: require './templates/edition_li'
  tagName: -> if @options.standalone then 'div' else 'li'
  className: -> if @options.standalone then 'editionLayout' else 'editionLi flex-row'

  regions:
    networkItemsRegion: '.networkItems'
    publicItemsRegion: '.publicItems'

  initialize: ->
    entityItems.initialize.call @
    if @standalone then app.execute 'metadata:update:needed'

  onShow: ->
    @model.waitForWork
    .then @render.bind(@)

    if @standalone
      @model.updateMetadata()
      .then app.Execute('metadata:update:done')

  onRender: -> entityItems.onRender.call @

  serializeData: ->
    _.extend @model.toJSON(),
      standalone: @standalone
      work: if @standalone then @model.work?.toJSON()

  events:
    'click .add': 'add'

  add: -> app.execute 'show:item:creation:form', { entity: @model }
