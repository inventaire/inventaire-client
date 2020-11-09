import { I18n } from 'modules/user/lib/i18n'
import editableEntity from './inv/editable_entity'
import { create as createEntity } from './create_entities'
import properties from './properties'
import Entity from '../models/entity'
import { buildPath } from 'lib/location'
import { asyncNoop, noop } from 'lib/utils'

const typeDefaultP31 = {
  human: 'wd:Q5',
  work: 'wd:Q47461344',
  serie: 'wd:Q277759',
  edition: 'wd:Q3331189',
  publisher: 'wd:Q2085381',
  collection: 'wd:Q20655472'
}

const propertiesShortlists = {
  human: [ 'wdt:P1412' ],
  work: [ 'wdt:P50' ],
  serie: [ 'wdt:P50' ],
  edition: [ 'wdt:P629', 'wdt:P1476', 'wdt:P1680', 'wdt:P123', 'invp:P2', 'wdt:P407', 'wdt:P577' ],
  publisher: [ 'wdt:P856', 'wdt:P112', 'wdt:P571', 'wdt:P576' ],
  collection: [ 'wdt:P1476', 'wdt:P123', 'wdt:P856' ]
}

export default {
  create (options) {
    let { type, label, claims, relation } = options

    // TODO: allow to select specific type at creation
    const defaultP31 = typeDefaultP31[type]
    if (defaultP31 == null) {
      throw new Error(`unknown type: ${type}`)
    }

    if (!claims) { claims = {} }
    claims['wdt:P31'] = [ defaultP31 ]

    const labels = {}
    if (label != null) {
      // use the label we got as a label suggestion
      labels[app.user.lang] = label
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
      invalidateRelationsCache: noop,
      saveLabel: asyncNoop,
      create () {
        return createEntity({
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

const getPropertiesShortlist = function (type, claims) {
  const typeShortlist = propertiesShortlists[type]
  if (typeShortlist == null) { return null }

  const claimsProperties = Object.keys(claims).filter(nonFixedEditor)
  const propertiesShortlist = propertiesShortlists[type].concat(claimsProperties)
  // If a serie was passed in the claims, invite to add an ordinal
  if (claimsProperties.includes('wdt:P179')) { propertiesShortlist.push('wdt:P1545') }

  return propertiesShortlist
}

const nonFixedEditor = function (prop) {
  // Testing properties[prop] existance as some properties don't
  // have an editor. Ex: wdt:P31
  const editorType = properties[prop]?.editorType
  if (!editorType) { return false }

  // Filter-out fixed editor: 'fixed-entity', 'fixed-string'
  if (editorType.split('-')[0] === 'fixed') { return false }

  return true
}
