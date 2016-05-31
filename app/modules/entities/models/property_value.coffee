properties = require 'modules/entities/lib/properties'

module.exports = Backbone.Model.extend
  initialize: (attr)->
    @updateValueEntity()
    # keep the grabbed entity up-to-date
    @on 'change:value', @updateValueEntity.bind(@)

  updateValueEntity: ->
    { property, value } = @toJSON()
    if value? and properties[property].type is 'entity'
      # TODO: make the whole entity stack use uris
      # instead of simple wikidata or inventaire ids
      @reqGrab 'get:entity:model:from:uri', "wd:#{value}", 'valueEntity'

  saveValue: (newValue)->
    oldValue = @get 'value'
    oldValueEntity = @valueEntity
    _.log oldValue, 'oldValue'
    _.log newValue, 'newValue'

    if newValue is oldValue then return _.preq.resolved

    property = @get 'property'

    if newValue? then @set 'value', newValue
    # else wait for server confirmation as it will trigger a model.destroy

    @valueEntity = null

    reverseAction = =>
      @set 'value', oldValue
      @valueEntity = oldValueEntity

    rollback = _.Rollback reverseAction, 'value_editor save'

    @entity.savePropertyValue property, oldValue, newValue
    .then @_destroyIfEmpty.bind(@, newValue)
    .catch rollback

  _destroyIfEmpty: (newValue)->
    if not newValue? then @destroy()
