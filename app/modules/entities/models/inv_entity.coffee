Entity = require './entity'
getBestLangValue = require '../lib/get_best_lang_value'
wd_ = require 'lib/wikidata'

module.exports = Entity.extend
  prefix: 'inv'
  initialize: (attr, options)->
    @refresh = options?.refresh
    @type = wd_.type @

    { lang } = app.user
    label = getBestLangValue lang, null, attr.labels

    uri = "#{@prefix}:#{@id}"
    canonical = pathname = "/entity/#{uri}"

    @set
      title: label
      label: label
      canonical: canonical
      pathname: pathname
      uri: uri
      editable:
        wiki: "#{pathname}/edit"

    # an object to store references to subentities collections
    # ex: @subentities['wdt:P629'] = thisBookEditionsCollection
    @subentities = {}

    @typeSpecificInitilize()

  getAuthorsString: ->
    unless @get('claims')?['wdt:P50']?.length > 0 then return _.preq.resolve ''
    uris = @get('claims')['wdt:P50']
    return wd_.getLabel uris, app.user.lang

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
    rollback = _.Rollback reverseAction, 'inv_entity setPropertyValue'

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
    # If creating, this model is a draft waiting to be send to the server for creation
    reverseAction = @set.bind @, labelPath, oldValue
    rollback = _.Rollback reverseAction, 'title_editor save'

    _.preq.put app.API.entities.inv.labels.update,
      id: @id
      lang: lang
      value: value
    .catch rollback

  typeSpecificInitilize: ->
    switch @type
      when 'book' then @initializeBook()
      when 'human' then @initializeAuthor()

  initializeBook: ->
    # property by which sub-entities are linked to this one
    @childrenClaimProperty = 'wdt:P629'
    @fetchSubEntities @refresh

  initializeAuthor: ->
    @childrenClaimProperty = 'wdt:P50'

  fetchSubEntities: (refresh)->
    uri = @get 'uri'

    @subentities[@childrenClaimProperty] = subentities = new Backbone.Collection

    _.preq.get app.API.entities.inv.idsByClaim @childrenClaimProperty, uri
    .get 'ids'
    .then (ids)-> app.request 'get:entities:models', 'inv', ids, refresh
    .then subentities.add.bind(subentities)
