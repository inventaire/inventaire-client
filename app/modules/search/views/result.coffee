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
    if _.isArray attrs.image then attrs.image = attrs.image[0]
    attrs.image = urlifyImageHash attrs.type, attrs.image
    return attrs

  events:
    'click a': 'showResultFromEvent'

  showResultFromEvent: (e)-> unless _.isOpenedOutside e then @showResult()
  showResult: ->
    { id, uri, label, type, image } = @model.toJSON()
    switch type
      when 'users'
        app.execute 'show:inventory:user', id
      when 'groups'
        app.execute 'show:inventory:group:byId', { groupId: id }
      when 'subjects'
        app.execute 'show:claim:entities', 'wdt:P921', uri
      else
        # Other cases are all entities
        app.execute 'show:entity', uri

    if uri?
      pictures = _.forceArray(image).map urlifyImageHash.bind(null, type)
      app.request 'search:history:add', { uri, label, type, pictures }

    app.vent.trigger 'live:search:show:result'

  unhighlight: -> @$el.removeClass 'highlight'
  highlight: -> @$el.addClass 'highlight'

urlifyImageHash = (type, hash)->
  nonEntityContainer = nonEntityContainersPerType[type]
  container = nonEntityContainer or 'entities'
  if _.isImageHash hash then "/img/#{container}/#{hash}"
  else hash

nonEntityContainersPerType =
  users: 'users'
  groups: 'users'
