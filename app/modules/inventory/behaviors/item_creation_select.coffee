module.exports = Marionette.Behavior.extend
  events:
    'click .select-button-group > .button': 'updateSelector'

  updateSelector: (e)->
    $el = $(e.currentTarget)
    $el.siblings().removeClass 'selected'
    $el.addClass 'selected'
    section = $el.parent()[0].id
    value = $el[0].id
    app.execute "last:#{section}:set", value
