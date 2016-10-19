WorksList = require './works_list'

module.exports = Marionette.LayoutView.extend
  template: require './templates/serie_layout'
  className: ->
    standalone = if @options.standalone then 'standalone' else ''
    return "serieLayout #{standalone}"

  regions:
    parts: '.parts'

  behaviors:
    WikiBar: {}

  initialize: ->
    @model.initSerieParts @options.refresh

  serializeData: ->
    _.extend @model.toJSON(),
      standalone: @options.standalone

  onShow: ->
    @model.waitForParts
    .then @showParts.bind(@)

  showParts: ->
    @parts.show new WorksList
      collection: @model.parts
      type: 'books'
      hideHeader: true
