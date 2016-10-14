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
    _.preq.put app.API.entities.inv.claims.update,
      id: @id
      property: property
      'new-value': newValue
      'old-value': oldValue
    .catch _.ErrorRethrow('savePropertyValue err')

  setLabel: (lang, value)->
    labelPath = "labels.#{lang}"
    oldValue = @get labelPath
    @set labelPath, value
    @saveLabel labelPath, oldValue, value

  saveLabel: (labelPath, oldValue, value)->
    reverseAction = @set.bind @, labelPath, oldValue
    rollback = _.Rollback reverseAction, 'title_editor save'

    _.preq.put app.API.entities.inv.labels.update,
      id: @id
      lang: app.user.lang
      value: value
    .catch rollback
