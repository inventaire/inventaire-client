module.exports = Marionette.CompositeView.extend
  tagName: 'li'
  template: require './templates/serie_cleanup_work'
  className: ->
    classes = 'serie-cleanup-work'
    if @model.get('isPlaceholder') then classes += ' placeholder'
    return classes

  childViewContainer: '.editionsContainer'
  childView: require './serie_cleanup_edition'

  initialize: ->
    @collection = @model.editions

  serializeData: ->
    _.extend @model.toJSON(),
      possibleOrdinals: @options.possibleOrdinals

  events:
    'change .ordinalSelector': 'updateOrdinal'

  updateOrdinal: (e)->
    { value } = e.currentTarget
    @model.setPropertyValue 'wdt:P1545', null, value
