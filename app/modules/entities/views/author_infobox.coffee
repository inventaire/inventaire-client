module.exports = Marionette.ItemView.extend
  template: require './templates/author_infobox'
  modelEvents:
    # The extract might arrive later
    'change:extract': 'render'

  serializeData: ->
    _.extend @model.toJSON(),
      standalone: @options.standalone
