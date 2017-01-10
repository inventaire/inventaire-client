SerieInfobox = require './serie_infobox'
WorksList = require './works_list'
behaviorsPlugin = require 'modules/general/plugins/behaviors'

module.exports = Marionette.LayoutView.extend
  template: require './templates/serie_layout'
  className: ->
    standalone = if @options.standalone then 'standalone' else ''
    return "serieLayout #{standalone}"

  regions:
    infobox: '.serieInfobox'
    parts: '.parts'

  behaviors:
    Loading: {}

  initialize: ->
    # Trigger fetchParts only once the author is in view
    @$el.once 'inview', @fetchParts.bind(@)

  serializeData: ->
    _.extend @model.toJSON(),
      standalone: @options.standalone

  onRender: ->
    @showInfobox()

  showInfobox: ->
    @infobox.show new SerieInfobox
      model: @model
      standalone: @options.standalone

  fetchParts: ->
    behaviorsPlugin.startLoading.call @

    @model.initSerieParts @options.refresh
    .then @showParts.bind(@)

  showParts: ->
    behaviorsPlugin.stopLoading.call @

    @parts.show new WorksList
      parentModel: @model
      collection: @model.parts
      title: 'works'
      type: 'work'
      hideHeader: true
      refresh: @options.refresh
