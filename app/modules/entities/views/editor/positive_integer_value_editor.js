import { isPositiveIntegerString } from 'lib/boolean_tests'
import ClaimsEditorCommons from './claims_editor_commons'
import forms_ from 'modules/general/lib/forms'
import error_ from 'lib/error'
import positiveIntegerValueEditorTemplate from './templates/positive_integer_value_editor.hbs'

const inputSelector = '.positive-integer-picker'

export default ClaimsEditorCommons.extend({
  mainClassName: 'positive-integer-value-editor',
  template: positiveIntegerValueEditorTemplate,

  ui: {
    input: inputSelector
  },

  initialize () {
    this.initEditModeState()
    this.focusTarget = 'input'
  },

  onRender () {
    return this.focusOnRender()
  },

  events: {
    'click .edit, .displayModeData': 'showEditMode',
    'click .cancel': 'hideEditMode',
    'click .save': 'save',
    'click .delete': 'delete',
    // Not setting a particular selector so that
    // any keyup event on the element triggers the event
    keyup: 'onKeyUp'
  },

  valueType: 'number',

  save () {
    let err
    const stringVal = this.ui.input.val()

    if (!isPositiveIntegerString(stringVal)) {
      err = error_.new('invalid number', stringVal)
      err.selector = inputSelector
      return forms_.alert(this, err)
    }

    const numberVal = parseInt(stringVal)

    const val = this.valueType === 'number' ? numberVal : stringVal

    // Ignore if we got the same value
    if (val === this.model.get('value')) { return this.hideEditMode() }

    if (numberVal < 1 || numberVal > 100000) {
      err = error_.new("number can't be higher than 100000", numberVal)
      err.selector = inputSelector
      return forms_.alert(this, err)
    }

    return this._save(val)
  }
})
