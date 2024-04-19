import { isEntityUri } from '#app/lib/boolean_tests'
import { formatAndThrowError } from '#app/lib/error'
import { getActionKey } from '#app/lib/key_events'
import AlertBox from '#behaviors/alert_box'
import mergeEntities from '#entities/views/editor/lib/merge_entities'
import { catchAlert } from '#general/lib/forms'
import workPickerTemplate from './templates/work_picker.hbs'

export default Marionette.View.extend({
  template: workPickerTemplate,

  ui: {
    workPickerSelect: '.workPickerSelect',
    workPickerValidate: '.validate',
  },

  initialize () {
    if (this.workPickerDisabled) return
    ({ worksWithOrdinal: this.worksWithOrdinal, worksWithoutOrdinal: this.worksWithoutOrdinal, _showWorkPicker: this._showWorkPicker } = this.options)
    if (this.workUri == null) this.workUri = this.options.workUri
    if (this.afterMerge == null) this.afterMerge = this.options.afterMerge
    if (this._showWorkPicker == null) this._showWorkPicker = false
  },

  onRender () {
    if (this.workPickerDisabled) return
    if (this._showWorkPicker) {
      this.setTimeout(this.ui.workPickerSelect.focus.bind(this.ui.workPickerSelect), 100)
      this.startListingForChanges()
    }
  },

  startListingForChanges () {
    if (this._listingForChanges) return
    this._listingForChanges = true
    this.listenTo(this.worksWithOrdinal, 'update', this.lazyRender.bind(this))
    this.listenTo(this.worksWithoutOrdinal, 'update', this.lazyRender.bind(this))
  },

  behaviors: {
    AlertBox,
  },

  events: {
    'click .showWorkPicker': 'showWorkPicker',
    'change .workPickerSelect': 'onSelectChange',
    'click .validate': 'selectWork',
    'keydown .workPickerSelect': 'onKeyDown',
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
    if (!isEntityUri(uri)) return
    const work = this.findWorkByUri(uri)
    if (work == null) return
    this.onWorkSelected(work)
  },

  showWorkPicker () {
    this._showWorkPicker = true
    this.lazyRender()
  },

  hideWorkPicker () {
    this._showWorkPicker = false
    this.lazyRender()
  },

  onSelectChange () {
    const uri = this.ui.workPickerSelect.val()
    if (isEntityUri(uri)) {
      this.ui.workPickerValidate.removeClass('hidden')
    } else {
      this.ui.workPickerValidate.addClass('hidden')
    }
  },

  getWorksList () {
    return this.worksWithOrdinal.serializeNonPlaceholderWorks()
    .concat(this.worksWithoutOrdinal.serializeNonPlaceholderWorks())
    .filter(work => work.uri !== this.workUri)
  },

  findWorkByUri (uri) {
    let work = this.worksWithOrdinal.findWhere({ uri })
    if (work != null) return work
    work = this.worksWithoutOrdinal.findWhere({ uri })
    if (work != null) return work
  },

  // Defaults: assume it as a work model that needs to be merged
  // Override the following methods for different behaviors
  serializeData () {
    return {
      worksList: this.getWorksList(),
      workPicker: {
        buttonIcon: 'compress',
        buttonLabel: 'merge',
        validateLabel: 'merge',
      },
    }
  },

  onWorkSelected (work) {
    const fromUri = this.model.get('uri')
    const toUri = work.get('uri')

    return this.model.fetchSubEntities()
    .then(() => mergeEntities(fromUri, toUri))
    .then(this.afterMerge.bind(this, work))
    .catch(formatAndThrowError('.workPicker', false))
    .catch(catchAlert.bind(null, this))
  },
})
