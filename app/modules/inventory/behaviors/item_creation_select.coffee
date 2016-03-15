module.exports = Marionette.Behavior.extend
  events:
    'click .select-button-group > .button': 'updateSelector'

  updateSelector: (e)->
    $el = $(e.currentTarget)
    $el.siblings().removeClass 'active'
    $el.addClass 'active'
