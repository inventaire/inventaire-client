PublisherInfobox = require './publisher_infobox'
EditionsList = require './editions_list'

module.exports = Marionette.LayoutView.extend
  className: ->
    className = 'publisherLayout'
    if @options.standalone then className += ' standalone'
    return className
  template: require './templates/publisher_layout'
  regions:
    infoboxRegion: '.publisherInfobox'
    editionsList: '#editionsList'

  initialize: ->
    { @refresh, @standalone } = @options
    @displayMergeSuggestions = app.user.isAdmin

  onShow: ->
    unless @standalone? then return

    @model.fetchSubEntities @refresh
    .then @ifViewIsIntact('showEditions')

  onRender: ->
    @showInfobox()

  showInfobox: ->
    @infoboxRegion.show new PublisherInfobox { @model, @standalone }

  showEditions: ->
    @editionsList.show new EditionsList { collection: @model.editions }
