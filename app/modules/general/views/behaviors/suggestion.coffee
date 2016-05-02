# Forked from: https://github.com/KyleNeedham/autocomplete/blob/master/src/autocomplete.childview.coffee

module.exports = Marionette.ItemView.extend
  tagName: 'li'
  className: 'ac-suggestion'
  template: require './templates/suggestion'

  events:
    'click': 'select'

  modelEvents:
    'highlight': 'highlight'
    'highlight:remove': 'removeHighlight'

  highlight: ->
    @trigger 'highlight'
    @$el.addClass 'active'

  removeHighlight: -> @$el.removeClass 'active'

  select: -> @model.trigger 'select', @model
