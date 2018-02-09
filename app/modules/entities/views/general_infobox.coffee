module.exports = Marionette.ItemView.extend
  className: 'generalInfobox'
  template: require './templates/general_infobox'
  behaviors:
    EntitiesCommons: {}
    ClampedExtract: {}

  initialize: ->
    # Also accept user models that will miss a getWikipediaExtract method
    @model.getWikipediaExtract?()
    { @small } = @options

  modelEvents:
    # The extract might arrive later
    'change:extract': 'render'

  serializeData: ->
    attrs = @model.toJSON()
    # Also accept user models
    attrs.extract or= attrs.bio
    attrs.image or= { url: attrs.picture }
    _.extend attrs,
      standalone: @options.standalone
      small: @small
