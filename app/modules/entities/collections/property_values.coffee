module.exports = Backbone.Collection.extend
  model: require '../models/property_value'
  initialize: (models, options)->
    { entity, property, claims } = options
    @property = property
    @entity = entity

  addClaimsValues: (claims)->
    # accept both an array of claims values or a single claim value
    claims = _.forceArray claims
    for value in claims
      @_add value
    return

  addEmptyValue: ->
    @_add null

  _add: (value)->
    model = @add
      value: value
      property: @property
    model.entity = @entity
    return model
