Patches = require '../../collections/patches'

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
    @set "#{propArrayPath}.#{index}", newValue

    reverseAction = @set.bind @, "#{propArrayPath}.#{index}", oldValue
    rollback = _.Rollback reverseAction, 'editable_entity setPropertyValue'

    return @savePropertyValue property, oldValue, newValue
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
    @saveLabel labelPath, lang, oldValue, value

  saveLabel: (labelPath, lang, oldValue, value)->
    reverseAction = @set.bind @, labelPath, oldValue
    rollback = _.Rollback reverseAction, 'title_editor save'

    _.preq.put app.API.entities.labels.update, { uri: @get('uri'), lang, value }
    .catch rollback

  fetchHistory: ->
    _.preq.get app.API.entities.history(@id)
    # reversing to get the last patches first
    .then (res)=> @history = new Patches res.patches.reverse()
