import forms_ from 'modules/general/lib/forms'

export default Marionette.ItemView.extend({
  tagName: 'li',
  className: 'entities-list-element-candidate',
  template: require('./templates/entities_list_element_candidate'),

  initialize () {
    let parentModel;
    ({ parentModel, listCollection: this.listCollection, childrenClaimProperty: this.childrenClaimProperty } = this.options)
    this.parentUri = parentModel.get('uri')
    const currentPropertyClaims = this.model.get(`claims.${this.childrenClaimProperty}`)
    this.alreadyAdded = this.isAlreadyAdded()
    return this.invClaimValueOnWdEntity = parentModel.get('isInvEntity') && this.model.get('isWikidataEntity')
  },

  behaviors: {
    AlertBox: {}
  },

  serializeData () {
    const attrs = this.model.toJSON()
    const { type } = attrs
    if (type != null) { attrs[type] = true }
    if (attrs.description == null) { attrs.description = _.i18n(type) }
    return _.extend(attrs, {
      alreadyAdded: this.alreadyAdded,
      invClaimValueOnWdEntity: this.invClaimValueOnWdEntity
    }
    )
  },

  events: {
    'click .add': 'add'
  },

  add () {
    this.listCollection.add(this.model)
    return this.model.setPropertyValue(this.childrenClaimProperty, null, this.parentUri)
    .then(() => {
      this.updateStatus()
      return app.execute('invalidate:entities:graph', this.parentUri)
    }).catch(forms_.catchAlert.bind(null, this))
  },

  updateStatus () {
    if (this.isAlreadyAdded()) {
      // Use classes instead of a re-render to prevent blinking {{claim}} labels
      this.$el.find('.add').addClass('hidden')
      return this.$el.find('.added').removeClass('hidden')
    } else {
      // Use classes instead of a re-render to prevent blinking {{claim}} labels
      this.$el.find('.add').removeClass('hidden')
      return this.$el.find('.added').addClass('hidden')
    }
  },

  isAlreadyAdded () {
    const currentPropertyClaims = this.model.get(`claims.${this.childrenClaimProperty}`)
    this.alreadyAdded = (currentPropertyClaims != null) && currentPropertyClaims.includes(this.parentUri)
    return this.alreadyAdded
  }
})
