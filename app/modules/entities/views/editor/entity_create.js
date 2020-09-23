/* eslint-disable
    import/no-duplicates,
    no-undef,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
import entityDraftModel from '../../lib/entity_draft_model'

export default Marionette.LayoutView.extend({
  id: 'entityCreate',
  template: require('./templates/entity_create'),

  regions: {
    typedEntityEdit: '#typedEntityEdit'
  },

  ui: {
    typePicker: '.typePicker'
  },

  events: {
    'click .typePicker a': 'updateTypePickerFromClick'
  },

  onShow () {
    const type = this.options.type || 'work'
    return this.selectType(type)
  },

  selectType (type) {
    this.showTypedEntityEdit(type)
    return this.updateTypePicker(type)
  },

  showTypedEntityEdit (type) {
    const { label, claims } = this.options
    const params = { type, label, claims }
    params.model = entityDraftModel.create(params)
    params.region = this.typedEntityEdit
    return app.execute('show:entity:edit:from:params', params)
  },

  updateTypePicker (type) {
    this.ui.typePicker.find('.selected').removeClass('selected')
    return this.ui.typePicker.find(`#${type}Picker`).addClass('selected')
  },

  updateTypePickerFromClick (e) {
    const type = e.currentTarget.id.replace('Picker', '')
    return this.selectType(type)
  }
})
