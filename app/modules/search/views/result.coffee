module.exports = Marionette.ItemView.extend
  className: 'result'
  tagName: 'li'
  template: require './templates/result'
  behaviors:
    PreventDefault: {}

  serializeData: ->
    attrs = @model.toJSON()
    # Prefer the alias type name to show 'author' instead of 'human'
    attrs.type = attrs.typeAlias or attrs.type
    return attrs

  events:
    'click a': 'showResultFromEvent'

  showResultFromEvent: (e)-> unless _.isOpenedOutside e then @showResult()
  showResult: ->
    switch @model.get('type')
      when 'users'
        app.execute 'show:inventory:user', @model.get('id')
      when 'groups'
        app.execute 'show:inventory:group:byId', @model.get('id')
      when 'subjects'
        app.execute 'show:claim:entities', 'wdt:P921', @model.get('uri')
      else
        # Other cases are all entities
        app.execute 'show:entity', @model.get('uri')

    app.vent.trigger 'live:search:show:result'

  unhighlight: -> @$el.removeClass 'highlight'
  highlight: -> @$el.addClass 'highlight'
