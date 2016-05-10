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
      propArray = @get "claims.#{property}"
      if oldValue not in propArray
        return error_.reject 'unknown property value', arguments

      index = propArray.indexOf oldValue
      @set "claims.#{property}.#{index}", newValue

      reverseAction = @set.bind @, "claims.#{property}.#{index}", oldValue
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
