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
