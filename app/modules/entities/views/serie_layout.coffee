TypedEntityLayout = require './typed_entity_layout'
EntitiesList = require './entities_list'
{ startLoading, stopLoading } = require 'modules/general/plugins/behaviors'

module.exports = TypedEntityLayout.extend
  template: require './templates/serie_layout'
  Infobox: require './serie_infobox'
  baseClassName: 'serieLayout'

  regions:
    infoboxRegion: '.serieInfobox'
    parts: '.parts'
    mergeSuggestionsRegion: '.mergeSuggestions'

  behaviors:
    Loading: {}

  initialize: ->
    TypedEntityLayout::initialize.call @
    # Trigger fetchParts only once the author is in view
    @$el.once 'inview', @fetchParts.bind(@)

  fetchParts: ->
    startLoading.call @

    @model.initSerieParts { @refresh }
    .then @ifViewIsIntact('showParts')

  showParts: ->
    stopLoading.call @

    @parts.show new EntitiesList
      parentModel: @model
      collection: @model.partsWithoutSuperparts
      title: 'works'
      type: 'work'
      hideHeader: true
      refresh: @refresh
