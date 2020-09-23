properties = require 'modules/entities/lib/properties'
regex_ = require 'lib/regex'
error_ = require 'lib/error'
entityDraftModel = require '../lib/entity_draft_model'

haveValueEntity = [ 'entity', 'fixed-entity' ]

module.exports = Backbone.Model.extend
  initialize: (attr)->
    @updateValueEntity()
    # keep the grabbed entity up-to-date
    @on 'change:value', @updateValueEntity.bind(@)

  updateValueEntity: ->
    { property, value } = @toJSON()
    { editorType } = properties[property]

    if value? and editorType in haveValueEntity

      if regex_.EntityUri.test value
        @reqGrab 'get:entity:model', value, 'valueEntity', true
      else if _.isObject(value) and value.claims?
        # Allow to pass an entity draft as an object of the form:
        # { labels: {}, claims: {} }
        # so that its creation is still pending, waiting for confirmation
        @valueEntity = entityDraftModel.create value
      else
        throw error_.new 'invalid entity uri', @toJSON()

  saveValue: (newValue)->
    oldValue = @get 'value'
    oldValueEntity = @valueEntity
    _.log oldValue, 'oldValue'
    _.log newValue, 'newValue'

    if newValue is oldValue then return Promise.resolve()

    property = @get 'property'

    if newValue? then @set 'value', newValue
    # else wait for server confirmation as it will trigger a model.destroy

    @valueEntity = null

    reverseAction = =>
      @set 'value', oldValue
      @valueEntity = oldValueEntity

    rollback = _.Rollback reverseAction, 'value_editor save'

    @entity.setPropertyValue property, oldValue, newValue
    .then @_destroyIfEmpty.bind(@, newValue)
    .catch rollback

  _destroyIfEmpty: (newValue)->
    if not newValue? then @destroy()
