module.exports = Marionette.ItemView.extend
  className: 'genreData'
  template: require './templates/genre_data'
  initialize: ->
    @listenTo @model, 'change', @render.bind(@)
