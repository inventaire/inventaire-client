import properties from 'modules/entities/lib/properties'
import regex_ from 'lib/regex'
import error_ from 'lib/error'
import entityDraftModel from '../lib/entity_draft_model'

const haveValueEntity = [ 'entity', 'fixed-entity' ]

export default Backbone.Model.extend({
  initialize (attr) {
    this.updateValueEntity()
    // keep the grabbed entity up-to-date
    return this.on('change:value', this.updateValueEntity.bind(this))
  },

  updateValueEntity () {
    const { property, value } = this.toJSON()
    const { editorType } = properties[property]

    if ((value != null) && haveValueEntity.includes(editorType)) {
      if (regex_.EntityUri.test(value)) {
        return this.reqGrab('get:entity:model', value, 'valueEntity', true)
      } else if (_.isObject(value) && (value.claims != null)) {
        // Allow to pass an entity draft as an object of the form:
        // { labels: {}, claims: {} }
        // so that its creation is still pending, waiting for confirmation
        return this.valueEntity = entityDraftModel.create(value)
      } else {
        throw error_.new('invalid entity uri', this.toJSON())
      }
    }
  },

  saveValue (newValue) {
    const oldValue = this.get('value')
    const oldValueEntity = this.valueEntity
    _.log(oldValue, 'oldValue')
    _.log(newValue, 'newValue')

    if (newValue === oldValue) { return Promise.resolve() }

    const property = this.get('property')

    if (newValue != null) { this.set('value', newValue) }
    // else wait for server confirmation as it will trigger a model.destroy

    this.valueEntity = null

    const reverseAction = () => {
      this.set('value', oldValue)
      return this.valueEntity = oldValueEntity
    }

    const rollback = _.Rollback(reverseAction, 'value_editor save')

    return this.entity.setPropertyValue(property, oldValue, newValue)
    .then(this._destroyIfEmpty.bind(this, newValue))
    .catch(rollback)
  },

  _destroyIfEmpty (newValue) {
    if ((newValue == null)) { return this.destroy() }
  }
})
