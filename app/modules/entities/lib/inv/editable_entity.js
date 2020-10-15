import assert_ from 'lib/assert_types'
import log_ from 'lib/loggers'
import { Rollback } from 'lib/utils'
import preq from 'lib/preq'
import Patches from '../../collections/patches'
import properties from '../properties'
import error_ from 'lib/error'

const propertiesUsedByRelations = [
  // Series and works use editions covers as illustrations
  'invp:P2',
  // Editions list are structured by lang
  'wdt:P407',
  // Works may infer their label from their editions title
  'wdt:P1476'
]

export default {
  async setPropertyValue (property, oldValue, newValue) {
    log_.info({ property, oldValue, newValue }, 'setPropertyValue args')
    assert_.string(property)
    if (oldValue === newValue) return

    const propArrayPath = `claims.${property}`
    let propArray = this.get(propArrayPath)
    if (propArray == null) {
      propArray = []
      this.set(propArrayPath, [])
    }

    // let pass null oldValue, it will create a claim
    if ((oldValue != null) && !propArray.includes(oldValue)) {
      throw error_.new('unknown property value', { property, oldValue, newValue })
    }

    // in cases of a new value, index is last index + 1 = propArray.length
    const index = (oldValue != null) ? propArray.indexOf(oldValue) : propArray.length
    propArray[index] = newValue
    // Compact propArray to remove deleted values
    this.set(propArrayPath, _.compact(propArray))

    const reverseAction = this.set.bind(this, `${propArrayPath}.${index}`, oldValue)
    const rollback = Rollback(reverseAction, 'editable_entity setPropertyValue')

    if (properties[property].editorType === 'entity') {
      app.execute('invalidate:entities:graph', [ oldValue, newValue ])
    }

    if (propertiesUsedByRelations.includes(property)) { this.invalidateRelationsCache() }

    return this.savePropertyValue(property, oldValue, newValue)
    // Triggering the event is required as NestedModel would trigger
    // 'add' and 'remove' events
    .then(() => this.trigger('change:claims', property, oldValue, newValue))
    .catch(rollback)
  },

  savePropertyValue (property, oldValue, newValue) {
    // Substitute an inv URI to the isbn URI to spare having to resolve it server-side
    const uri = this.get('altUri') || this.get('uri')
    return preq.put(app.API.entities.claims.update, {
      uri,
      property,
      'new-value': newValue,
      'old-value': oldValue
    })
    .catch(log_.ErrorRethrow('savePropertyValue err'))
  },

  setLabel (lang, value) {
    const labelPath = `labels.${lang}`
    const oldValue = this.get(labelPath)
    this.set(labelPath, value)
    app.execute('invalidate:entities:cache', this.get('uri'))
    return this.saveLabel(labelPath, lang, oldValue, value)
  },

  saveLabel (labelPath, lang, oldValue, value) {
    const reverseAction = this.set.bind(this, labelPath, oldValue)
    const rollback = Rollback(reverseAction, 'saveLabel')

    return preq.put(app.API.entities.labels.update, { uri: this.get('uri'), lang, value })
    .catch(rollback)
  },

  fetchHistory (uri) {
    const id = this.id || uri.split(':')[1]
    return preq.get(app.API.entities.history(id))
    // reversing to get the last patches first
    .then(res => { this.history = new Patches(res.patches.reverse()) })
  },

  // Invalidating the entity's and its relatives cache
  // so that next time a layout displays one of those entities
  // it takes in account the changes we just saved
  invalidateRelationsCache () {
    const { uri, type, claims } = this.toJSON()
    let uris = [ uri ]

    // Invalidate relative entities too
    switch (type) {
    case 'edition':
      uris.push(claims['wdt:P629'])
      break
    case 'work':
      uris.push(claims['wdt:P50'])
      uris.push(claims['wdt:P179'])
      break
    }

    uris = _.compact(_.flatten(uris))

    app.execute('invalidate:entities:cache', uris)
  }
}
