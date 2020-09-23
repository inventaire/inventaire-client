/* eslint-disable
    import/no-duplicates,
    no-undef,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
import getActionKey from 'lib/get_action_key'
import mergeEntities from 'modules/entities/views/editor/lib/merge_entities'
import forms_ from 'modules/general/lib/forms'
import error_ from 'lib/error'

export default Marionette.ItemView.extend({
  template: require('./templates/work_picker'),

  ui: {
    workPickerSelect: '.workPickerSelect',
    workPickerValidate: '.validate'
  },

  initialize () {
    if (this.workPickerDisabled) { return }
    ({ worksWithOrdinal: this.worksWithOrdinal, worksWithoutOrdinal: this.worksWithoutOrdinal, _showWorkPicker: this._showWorkPicker } = this.options)
    if (this.workUri == null) { this.workUri = this.options.workUri }
    if (this.afterMerge == null) { this.afterMerge = this.options.afterMerge }
    return this._showWorkPicker != null ? this._showWorkPicker : (this._showWorkPicker = false)
  },

  onRender () {
    if (this.workPickerDisabled) { return }
    if (this._showWorkPicker) {
      this.setTimeout(this.ui.workPickerSelect.focus.bind(this.ui.workPickerSelect), 100)
      return this.startListingForChanges()
    }
  },

  startListingForChanges () {
    if (this._listingForChanges) { return }
    this._listingForChanges = true
    this.listenTo(this.worksWithOrdinal, 'update', this.lazyRender.bind(this))
    return this.listenTo(this.worksWithoutOrdinal, 'update', this.lazyRender.bind(this))
  },

  behaviors: {
    AlertBox: {}
  },

  events: {
    'click .showWorkPicker': 'showWorkPicker',
    'change .workPickerSelect': 'onSelectChange',
    'click .validate': 'selectWork',
    'keydown .workPickerSelect': 'onKeyDown'
  },

  onKeyDown (e) {
    const key = getActionKey(e)
    switch (key) {
    case 'esc': return this.hideWorkPicker()
    case 'enter': return this.selectWork()
    }
  },

  selectWork () {
    const uri = this.ui.workPickerSelect.val()
    if (!_.isEntityUri(uri)) { return }
    const work = this.findWorkByUri(uri)
    if (work == null) { return }
    return this.onWorkSelected(work)
  },

  showWorkPicker () {
    this._showWorkPicker = true
    return this.lazyRender()
  },

  hideWorkPicker () {
    this._showWorkPicker = false
    return this.lazyRender()
  },

  onSelectChange () {
    const uri = this.ui.workPickerSelect.val()
    if (_.isEntityUri(uri)) {
      return this.ui.workPickerValidate.removeClass('hidden')
    } else { return this.ui.workPickerValidate.addClass('hidden') }
  },

  getWorksList () {
    return this.worksWithOrdinal.serializeNonPlaceholderWorks()
    .concat(this.worksWithoutOrdinal.serializeNonPlaceholderWorks())
    .filter(work => work.uri !== this.workUri)
  },

  findWorkByUri (uri) {
    let work = this.worksWithOrdinal.findWhere({ uri })
    if (work != null) { return work }
    work = this.worksWithoutOrdinal.findWhere({ uri })
    if (work != null) { return work }
  },

  // Defaults: assume it as a work model that needs to be merged
  // Override the following methods for different behaviors
  serializeData () {
    return {
      worksList: this.getWorksList(),
      workPicker: {
        buttonIcon: 'compress',
        buttonLabel: 'merge',
        validateLabel: 'merge'
      }
    }
  },

  onWorkSelected (work) {
    const fromUri = this.model.get('uri')
    const toUri = work.get('uri')

    return this.model.fetchSubEntities()
    .then(() => mergeEntities(fromUri, toUri))
    .then(this.afterMerge.bind(this, work))
    .catch(error_.Complete('.workPicker', false))
    .catch(forms_.catchAlert.bind(null, this))
  }
})
