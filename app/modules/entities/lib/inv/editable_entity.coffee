Patches = require '../../collections/patches'
properties = require '../properties'
propertiesUsedByRelations = [
  # Series and works use editions covers as illustrations
  'invp:P2'
  # Editions list are structured by lang
  'wdt:P407'
  # Works may infer their label from their editions title
  'wdt:P1476'
]

module.exports =
  setPropertyValue: (property, oldValue, newValue)->
    _.log arguments, 'setPropertyValue args'
    if oldValue is newValue then return _.preq.resolved

    propArrayPath = "claims.#{property}"
    propArray = @get propArrayPath
    unless propArray?
      propArray = []
      @set propArrayPath, []

    # let pass null oldValue, it will create a claim
    if oldValue? and oldValue not in propArray
      return error_.reject 'unknown property value', arguments

    # in cases of a new value, index is last index + 1 = propArray.length
    index = if oldValue? then propArray.indexOf(oldValue) else propArray.length
    propArray[index] = newValue
    # Compact propArray to remove deleted values
    @set propArrayPath, _.compact(propArray)

    reverseAction = @set.bind @, "#{propArrayPath}.#{index}", oldValue
    rollback = _.Rollback reverseAction, 'editable_entity setPropertyValue'

    if properties[property].editorType is 'entity'
      # Invalidate entities that might need to update their graph data
      # following this change
      app.execute 'invalidate:entities:cache', _.compact([ oldValue, newValue ])

    if property in propertiesUsedByRelations then @invalidateRelationsCache()

    return @savePropertyValue property, oldValue, newValue
    # Triggering the event is required as Backbone.NestedModel would trigger
    # 'add' and 'remove' events
    .then => @trigger 'change:claims', property, oldValue, newValue
    .catch rollback

  savePropertyValue: (property, oldValue, newValue)->
    # Substitute an inv URI to the isbn URI to spare having to resolve it server-side
    uri = @get('altUri') or @get('uri')
    _.preq.put app.API.entities.claims.update,
      uri: uri
      property: property
      'new-value': newValue
      'old-value': oldValue
    .catch _.ErrorRethrow('savePropertyValue err')

  setLabel: (lang, value)->
    labelPath = "labels.#{lang}"
    oldValue = @get labelPath
    @set labelPath, value
    app.execute 'invalidate:entities:cache', @get('uri')
    return @saveLabel labelPath, lang, oldValue, value

  saveLabel: (labelPath, lang, oldValue, value)->
    reverseAction = @set.bind @, labelPath, oldValue
    rollback = _.Rollback reverseAction, 'title_editor save'

    _.preq.put app.API.entities.labels.update, { uri: @get('uri'), lang, value }
    .catch rollback

  fetchHistory: ->
    _.preq.get app.API.entities.history(@id)
    # reversing to get the last patches first
    .then (res)=> @history = new Patches res.patches.reverse()

  # Invalidating the entity's and its relatives cache
  # so that next time a layout displays one of those entities
  # it takes in account the changes we just saved
  invalidateRelationsCache: ->
    { uri, type, claims } = @toJSON()
    uris = [ uri ]

    # Invalidate relative entities too
    switch type
      when 'edition'
        uris.push claims['wdt:P629']
      when 'work'
        uris.push claims['wdt:P50']
        uris.push claims['wdt:P179']

    uris = _.compact _.flatten(uris)

    app.execute 'invalidate:entities:cache', uris
