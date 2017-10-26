module.exports = Marionette.ItemView.extend
  className: 'innerInfobox'
  template: require './templates/general_infobox'
  behaviors:
    EntitiesCommons: {}

  initialize: ->
    @model.getWikipediaExtract()

  modelEvents:
    # The extract might arrive later
    'change:extract': 'render'

  serializeData: ->
    _.extend @model.toJSON(),
      standalone: @options.standalone
