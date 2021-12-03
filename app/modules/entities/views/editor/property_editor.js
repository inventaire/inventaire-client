import isLoggedIn from './lib/is_logged_in'
import creationParials from './lib/creation_partials'
import EntityValueEditor from './entity_value_editor'
import FixedEntityValue from './fixed_entity_value'
import StringValueEditor from './string_value_editor'
import FixedStringValue from './fixed_string_value'
import SimpleDayValueEditor from './simple_day_value_editor'
import PositiveIntegerValueEditor from './positive_integer_value_editor'
import PositiveIntegerStringValueEditor from './positive_integer_string_value_editor'
import ImageValueEditor from './image_value_editor'
import propertyEditorTemplate from './templates/property_editor.hbs'
import AlertBox from 'behaviors/alert_box'
import PreventDefault from 'behaviors/prevent_default'

const editors = {
  entity: EntityValueEditor,
  'fixed-entity': FixedEntityValue,
  string: StringValueEditor,
  'fixed-string': FixedStringValue,
  'simple-day': SimpleDayValueEditor,
  'positive-integer': PositiveIntegerValueEditor,
  'positive-integer-string': PositiveIntegerStringValueEditor,
  image: ImageValueEditor,
}

export default Marionette.CollectionView.extend({
  className () {
    const specificClass = 'property-editor-' + this.model.get('editorType')
    return `property-editor ${specificClass}`
  },

  template: propertyEditorTemplate,
  childView () { return editors[this.model.get('editorType')] },
  childViewContainer: '.values',

  behaviors: {
    // May be required by customAdd creation partials
    AlertBox,
    PreventDefault,
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
    this.customAdd = creationParials[this.property]

    if (this.property.startsWith('invp:') && this.model.entity.get('isWikidataEntity')) {
      this.invPropertyOnWikidataEntity = true
    }
  },

  serializeData () {
    if (this.shouldBeHidden) return
    const attrs = this.model.toJSON()
    if (this.customAdd) {
      attrs.customAdd = true
      attrs[`creation_partial_is_${this.customAdd.partial}`] = true
      attrs.creationPartialData = this.customAdd.partialData(this.model.entity)
    } else {
      attrs.canAddValues = this.canAddValues()
    }
    attrs.invPropertyOnWikidataEntity = this.invPropertyOnWikidataEntity
    return attrs
  },

  onRender () {
    if (this.shouldBeHidden) this.$el.hide()
  },

  canAddValues () {
    return this.model.get('multivalue') || (this.collection.length === 0)
  },

  events: {
    'click .addValue': 'addValue',
    'click .creationPartial a': 'dispatchCreationPartialClickEvents'
  },

  ui: {
    addValueButton: '.addValue'
  },

  addValue (e) {
    if (isLoggedIn()) this.collection.addEmptyValue()
    // Prevent parent views including the same 'click .addValue': 'addValue'
    // event listener to be triggered
    e.stopPropagation()
  },

  updateAddValueButton () {
    if (this.collection.length === 0) {
      this.ui.addValueButton.show()
    } else {
      this.ui.addValueButton.hide()
    }
  },

  dispatchCreationPartialClickEvents (e) {
    const { id } = e.currentTarget
    return this.customAdd.clickEvents[id]?.({ view: this, work: this.model.entity, e })
  }
})
