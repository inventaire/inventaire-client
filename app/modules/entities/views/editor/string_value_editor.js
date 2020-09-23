import ClaimsEditorCommons from './claims_editor_commons';
import forms_ from 'modules/general/lib/forms';
import error_ from 'lib/error';
const inputSelector = '.string-value-input';
import { initEditionTitleTip, tipOnKeyup, tipOnRender } from './lib/title_tip';

export default ClaimsEditorCommons.extend({
  mainClassName: 'string-value-editor',
  template: require('./templates/string_value_editor'),

  ui: {
    input: 'input',
    tip: '.tip'
  },

  initialize() {
    this.focusTarget = 'input';
    this.initEditModeState();
    return initEditionTitleTip.call(this, this.model.entity, this.model.get('property'));
  },

  serializeData() {
    const attrs = this.model.toJSON();
    attrs.editMode = this.editMode;
    attrs.editable = true;
    return attrs;
  },

  onRender() {
    this.focusOnRender();
    return tipOnRender.call(this);
  },

  events: {
    'click .edit, .displayModeData': 'showEditMode',
    'click .cancel': 'hideEditMode',
    'click .save': 'save',
    'click .delete': 'delete',
    // Not setting a particular selector so that
    // any keyup event on the element triggers the event
    'keyup': 'onKeyupCustom'
  },

  save() {
    const val = this.ui.input.val().trim();

    if (!_.isNonEmptyString(val)) {
      const err = error_.new("can't be empty", val);
      err.selector = inputSelector;
      return forms_.alert(this, err);
    }

    // Ignore if we got the same value
    if (val === this.model.get('value')) { return this.hideEditMode(); }

    return this._save(val);
  },

  onKeyupCustom(e){
    this.onKeyUp(e);
    return tipOnKeyup.call(this, e);
  }
});
