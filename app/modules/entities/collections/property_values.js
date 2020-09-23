PropertyValueModel = require '../models/property_value'

module.exports = Backbone.Collection.extend
  model: PropertyValueModel
  initialize: (models, options)->
    { @entity, @property, @allowEntityCreation } = options

  addClaimsValues: (claims)->
    # accept both an array of claims values or a single claim value
    claims = _.forceArray claims
    for value in claims
      @addByValue value
    return

  addEmptyValue: ->
    @addByValue null

  addByValue: (value)->
    # Create the model before adding it to the collection to be able
    # to attach the entity before any view runs its initialize function
    # as they might depend on model.entity being set
    model = new PropertyValueModel
      value: value
      property: @property
      allowEntityCreation: @allowEntityCreation
    model.entity = @entity
    @add model
    return model
