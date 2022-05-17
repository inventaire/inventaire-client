import { I18n } from '#user/lib/i18n'
import editableEntity from './inv/editable_entity.js'
import { createAndGetEntityModel } from './create_entities.js'
import Entity from '../models/entity.js'
import { buildPath } from '#lib/location'
import { asyncNoop } from '#lib/utils'
import { typeDefaultP31 } from '#entities/lib/types/entities_types'
import { getPropertiesShortlist } from '#entities/components/editor/lib/create_helpers'

const hasMonolingualTitle = [
  'collection'
]

export default {
  create (options) {
    let { type, label, claims, relation } = options

    // TODO: allow to select specific type at creation
    const defaultP31 = typeDefaultP31[type]
    if (defaultP31 == null) {
      throw new Error(`unknown type: ${type}`)
    }

    if (!claims) claims = {}
    claims['wdt:P31'] = [ defaultP31 ]

    const labels = {}
    if (label != null) {
      if (hasMonolingualTitle.includes(type)) {
        claims['wdt:P1476'] = [ label ]
      } else {
        // use the label we got as a label suggestion
        labels[app.user.lang] = label
      }
    }

    const model = new Backbone.NestedModel({ type, labels, claims })
    Entity.prototype.setFavoriteLabel.call(model, model.toJSON())

    _.extend(model, {
      type,
      creating: true,
      // The property that links this entity to another entity being created
      relation,
      propertiesShortlist: getPropertiesShortlist(type, claims),
      setPropertyValue: editableEntity.setPropertyValue.bind(model),
      savePropertyValue: asyncNoop,
      setLabel: editableEntity.setLabel.bind(model),
      resetLabels (lang, value) {
        this.set('labels', {})
        return this.setLabel(lang, value)
      },
      // Required by editableEntity.setPropertyValue
      invalidateRelationsCache: _.noop,
      saveLabel: asyncNoop,
      create () {
        return createAndGetEntityModel({
          labels: this.get('labels'),
          claims: this.get('claims')
        })
      },
      fetchSubEntities: Entity.prototype.fetchSubEntities,
      fetchSubEntitiesUris: Entity.prototype.fetchSubEntitiesUris,

      // Methods required by app.navigateFromModel
      updateMetadata () { return { title: label || I18n('new entity') } },
      getRefresh: _.identity
    })

    // Attributes required by app.navigateFromModel
    model.set('edit', buildPath('/entity/new', options))

    Entity.prototype.typeSpecificInit.call(model)

    return model
  },

  allowlistedTypes: Object.keys(typeDefaultP31)
}
