PublisherInfobox = require './publisher_infobox'

module.exports = Marionette.LayoutView.extend
  className: 'publisherLayout'
  template: require './templates/publisher_layout'
  regions:
    infoboxRegion: '.publisherInfobox'

  serializeData: ->
    _.extend @model.toJSON(),
      canRefreshData: true

  onRender: ->
    @showInfobox()

  showInfobox: ->
    @infoboxRegion.show new PublisherInfobox { @model, @standalone }

