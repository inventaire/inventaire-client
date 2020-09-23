/* eslint-disable
    import/no-duplicates,
    no-return-assign,
    no-undef,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
import ClaimsEditorCommons from './claims_editor_commons'
import forms_ from 'modules/general/lib/forms'
import error_ from 'lib/error'
const inputSelector = '.positive-integer-picker'

export default ClaimsEditorCommons.extend({
  mainClassName: 'positive-integer-value-editor',
  template: require('./templates/positive_integer_value_editor'),

  ui: {
    input: inputSelector
  },

  initialize () {
    this.initEditModeState()
    return this.focusTarget = 'input'
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

    if (!_.isPositiveIntegerString(stringVal)) {
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
