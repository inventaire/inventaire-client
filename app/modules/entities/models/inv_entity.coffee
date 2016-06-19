Entity = require './entity'
getBestLangValue = require '../lib/get_best_lang_value'
wd_ = require 'lib/wikidata'
error_ = require 'lib/error'

module.exports = Entity.extend
  prefix: 'inv'
  initialize: (attr)->
    @type = wd_.type @

    { lang } = app.user
    label = getBestLangValue lang, null, attr.labels

    canonical = pathname = "/entity/#{@prefix}:#{@id}"

    if title = @get('title')
      pathname += '/' + _.softEncodeURI(title)

    @set
      title: label
      label: label
      canonical: canonical
      pathname: pathname
      uri: "#{@prefix}:#{@id}"
      domain: 'inv'
      wikidata:
        wiki: "#{pathname}/edit"

  getAuthorsString: ->
    unless @get('claims')?.P50?.length > 0 then return _.preq.resolve ''
    qids = @get('claims').P50
    return wd_.getLabel qids, app.user.lang

  savePropertyValue: (property, oldValue, newValue)->
    _.log arguments, 'savePropertyValue args'
    if oldValue isnt newValue
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
      rollback = _.Rollback reverseAction, 'inv_entity savePropertyValue'

      _.preq.put app.API.entities.inv.claims.update,
        id: @id
        property: property
        'new-value': newValue
        'old-value': oldValue
      .catch rollback
      .catch _.ErrorRethrow('savePropertyValue err')

    else
      _.preq.resolved
