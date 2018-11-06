SerieInfobox = require './serie_infobox'
WorksList = require './works_list'
behaviorsPlugin = require 'modules/general/plugins/behaviors'

module.exports = Marionette.LayoutView.extend
  template: require './templates/serie_layout'
  className: ->
    standalone = if @options.standalone then 'standalone' else ''
    return "serieLayout #{standalone} #{@cid}"

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
    behaviorsPlugin.startLoading.call @, ".#{@cid}"

    @model.initSerieParts { @refresh }
    .then @ifViewIsIntact('showParts')

  showParts: ->
    behaviorsPlugin.stopLoading.call @, ".#{@cid}"

    @parts.show new WorksList
      parentModel: @model
      collection: @model.parts
      title: 'works'
      type: 'work'
      hideHeader: true
      refresh: @refresh
