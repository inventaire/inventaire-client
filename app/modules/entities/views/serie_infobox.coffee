module.exports = Marionette.ItemView.extend
  template: require './templates/serie_infobox'
  modelEvents:
    # The description might be overriden by a Wikipedia extract arrive later
    'change:description': 'render'

  serializeData: ->
    { standalone } = @options
    _.extend @model.toJSON(),
      headerLevel: if standalone then 'h3' else 'h4'
