SerieInfobox = require './serie_infobox'
EntitiesList = require './entities_list'
{ startLoading, stopLoading } = require 'modules/general/plugins/behaviors'

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
    { @standalone, @refresh } = @options
    # Trigger fetchParts only once the author is in view
    @$el.once 'inview', @fetchParts.bind(@)

  serializeData: -> _.extend @model.toJSON(), { @standalone }

  onRender: ->
    @showInfobox()

  showInfobox: ->
    @infobox.show new SerieInfobox { @model, @standalone }

  fetchParts: ->
    startLoading.call @

    @model.initSerieParts { @refresh }
    .then @ifViewIsIntact('showParts')

  showParts: ->
    stopLoading.call @

    @parts.show new EntitiesList
      parentModel: @model
      collection: @model.parts
      title: 'works'
      type: 'work'
      hideHeader: true
      refresh: @refresh
