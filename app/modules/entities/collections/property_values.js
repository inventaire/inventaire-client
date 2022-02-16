import { forceArray } from '#lib/utils'
import PropertyValueModel from '../models/property_value'

export default Backbone.Collection.extend({
  model: PropertyValueModel,
  initialize (models, options) {
    return ({ entity: this.entity, property: this.property, allowEntityCreation: this.allowEntityCreation } = options)
  },

  addClaimsValues (claims) {
    // accept both an array of claims values or a single claim value
    claims = forceArray(claims)
    for (const value of claims) {
      this.addByValue(value)
    }
  },

  addEmptyValue () {
    return this.addByValue(null)
  },

  addByValue (value) {
    // Create the model before adding it to the collection to be able
    // to attach the entity before any view runs its initialize function
    // as they might depend on model.entity being set
    const model = new PropertyValueModel({
      value,
      property: this.property,
      allowEntityCreation: this.allowEntityCreation
    })
    model.entity = this.entity
    this.add(model)
    return model
  }
})
