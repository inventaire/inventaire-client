# Forked from: https://github.com/KyleNeedham/autocomplete/blob/master/src/autocomplete.childview.coffee

module.exports = Marionette.ItemView.extend
  tagName: 'li'
  className: 'autocomplete-suggestion'
  template: require './templates/autocomplete_suggestion'

  events:
    'click .select': 'select'

  modelEvents:
    'highlight': 'highlight'
    'highlight:remove': 'removeHighlight'

  highlight: ->
    @trigger 'highlight'
    @$el.addClass 'active'

  removeHighlight: -> @$el.removeClass 'active'

  select: -> @triggerMethod 'select:from:click', @model
