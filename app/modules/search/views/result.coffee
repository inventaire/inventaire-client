module.exports = Marionette.ItemView.extend
  className: 'result'
  template: require './templates/result'
  behaviors:
    PreventDefault: {}

  events:
    'click a': 'showResultFromEvent'

  showResultFromEvent: (e)-> unless _.isOpenedOutside e then @showResult()
  showResult: ->
    switch @model.get('type')
      when 'users'
        app.execute 'show:inventory:user', @model.get('id')
      when 'groups'
        app.execute 'show:inventory:group:byId', @model.get('id')
      else
        # Other cases are all entities
        app.execute 'show:entity', @model.get('uri')

    app.vent.trigger 'live:search:show:result'

  unhighlight: -> @$el.removeClass 'highlight'
  highlight: -> @$el.addClass 'highlight'
