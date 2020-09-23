import isLoggedIn from './lib/is_logged_in'
import creationParials from './lib/creation_partials'

const editors = {
  entity: require('./entity_value_editor'),
  'fixed-entity': require('./fixed_entity_value'),
  string: require('./string_value_editor'),
  'fixed-string': require('./fixed_string_value'),
  'simple-day': require('./simple_day_value_editor'),
  'positive-integer': require('./positive_integer_value_editor'),
  'positive-integer-string': require('./positive_integer_string_value_editor'),
  image: require('./image_value_editor')
}

export default Marionette.CompositeView.extend({
  className () {
    const specificClass = 'property-editor-' + this.model.get('editorType')
    return `property-editor ${specificClass}`
  },

  template: require('./templates/property_editor'),
  getChildView () { return editors[this.model.get('editorType')] },
  childViewContainer: '.values',

  behaviors: {
    // May be required by customAdd creation partials
    AlertBox: {},
    PreventDefault: {}
  },

  initialize () {
    this.collection = this.model.values

    const fixedValue = this.model.get('editorType').split('-')[0] === 'fixed'
    const noValue = this.collection.length === 0
    if (fixedValue && noValue) {
      this.shouldBeHidden = true
      return
    }

    if (!this.model.get('multivalue')) {
      this.listenTo(this.collection, 'add remove', this.updateAddValueButton.bind(this))
    }

    this.property = this.model.get('property')
    return this.customAdd = creationParials[this.property]
  },

  serializeData () {
    if (this.shouldBeHidden) { return }
    const attrs = this.model.toJSON()
    if (this.customAdd) {
      attrs.customAdd = true
      attrs.creationPartial = 'entities:editor:' + this.customAdd.partial
      attrs.creationPartialData = this.customAdd.partialData(this.model.entity)
    } else {
      attrs.canAddValues = this.canAddValues()
    }
    return attrs
  },

  onShow () {
    if (this.shouldBeHidden) { return this.$el.hide() }
  },

  canAddValues () { return this.model.get('multivalue') || (this.collection.length === 0) },

  events: {
    'click .addValue': 'addValue',
    'click .creationPartial a': 'dispatchCreationPartialClickEvents'
  },

  ui: {
    addValueButton: '.addValue'
  },

  addValue (e) {
    if (isLoggedIn()) { this.collection.addEmptyValue() }
    // Prevent parent views including the same 'click .addValue': 'addValue'
    // event listener to be triggered
    return e.stopPropagation()
  },

  updateAddValueButton () {
    if (this.collection.length === 0) {
      return this.ui.addValueButton.show()
    } else { return this.ui.addValueButton.hide() }
  },

  dispatchCreationPartialClickEvents (e) {
    const { id } = e.currentTarget
    return this.customAdd.clickEvents[id]?.({ view: this, work: this.model.entity, e })
  }
})
