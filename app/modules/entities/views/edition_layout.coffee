entityItems = require '../lib/entity_items'
EntityActions = require './entity_actions'

module.exports = Marionette.LayoutView.extend
  getTemplate: ->
    if @options.standalone then require './templates/edition_layout'
    else require './templates/edition_li'
  tagName: -> if @options.standalone then 'div' else 'li'
  className: ->
    base = 'edition-commons'
    if @options.standalone then "#{base} editionLayout" else "#{base} editionLi"

  regions:
    personalItemsRegion: '.personalItems'
    networkItemsRegion: '.networkItems'
    publicItemsRegion: '.publicItems'
    entityActions: '#entityActions'

  initialize: ->
    entityItems.initialize.call @
    if @standalone then app.execute 'metadata:update:needed'

  onShow: ->
    @model.waitForWork
    .then @render.bind(@)

    # Need to wait to know if the user has an instance of this work
    @waitForItems.then @showEntityActions.bind(@)

    if @standalone
      @model.updateMetadata()
      .then app.Execute('metadata:update:done')

  onRender: -> entityItems.onRender.call @

  serializeData: ->
    _.extend @model.toJSON(),
      standalone: @standalone
      work: if @standalone then @model.work?.toJSON()

  # Unclear why, but @entityActions may be undefined at render
  showEntityActions: -> @entityActions?.show new EntityActions { @model }
