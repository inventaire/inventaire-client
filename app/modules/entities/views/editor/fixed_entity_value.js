import fixedEntityValueTemplate from './templates/fixed_entity_value.hbs'

export default Marionette.View.extend({
  template: fixedEntityValueTemplate,
  className: 'fixed-entity-value fixed-value value-editor-commons',

  initialize () {
    this.draftValueEntity = this.model.valueEntity?.creating
  },

  serializeData () {
    if (this.draftValueEntity) return this.draftModelData()

    const attrs = this.model.toJSON()
    attrs.valueEntity = this.valueEntityData()
    attrs.value = attrs.valueEntity?.label || attrs.value
    if (attrs.valueEntity != null) {
      const hasIdentifierTooltipLinks = (attrs.valueEntity.type != null) || (attrs.valueEntity.wikidata != null)
      attrs.valueEntity.hasIdentifierTooltipLinks = hasIdentifierTooltipLinks
      attrs.valueEntity.contrast = true
    }
    return attrs
  },

  valueEntityData () {
    const { valueEntity } = this.model
    if (valueEntity != null) return valueEntity.toJSON()
  },

  onShow () {
    this.listenTo(this.model, 'grab', this.onGrab.bind(this))
  },

  onGrab () {
    if (this.model.valueEntity != null) {
      this.listenToOnce(this.model.valueEntity, 'change:image', this.lazyRender.bind(this))
    }

    this.lazyRender()
  },

  draftModelData () {
    const draftModel = this.model.valueEntity
    return {
      draft: true,
      label: _.values(draftModel.get('labels'))[0]
    }
  }
})
