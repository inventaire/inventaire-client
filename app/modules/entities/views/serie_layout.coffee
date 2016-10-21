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
    # Trigger fetchParts only once the author is in view
    @$el.once 'inview', @fetchParts.bind(@)

  serializeData: ->
    _.extend @model.toJSON(),
      standalone: @options.standalone

  fetchParts: ->
    @model.initSerieParts @options.refresh
    .then @showParts.bind(@)

  showParts: ->
    @parts.show new WorksList
      collection: @model.parts
      type: 'books'
      hideHeader: true
