import entityDraftModel from '../../lib/entity_draft_model'
import entityCreateTemplate from './templates/entity_create.hbs'
import 'modules/entities/scss/entity_create.scss'

export default Marionette.View.extend({
  id: 'entityCreate',
  template: entityCreateTemplate,

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
    this.selectType(type)
  },

  selectType (type) {
    this.showTypedEntityEdit(type)
    this.updateTypePicker(type)
  },

  showTypedEntityEdit (type) {
    const { label, claims } = this.options
    const params = { type, label, claims }
    params.model = entityDraftModel.create(params)
    params.region = this.typedEntityEdit
    app.execute('show:entity:edit:from:params', params)
  },

  updateTypePicker (type) {
    this.ui.typePicker.find('.selected').removeClass('selected')
    this.ui.typePicker.find(`#${type}Picker`).addClass('selected')
  },

  updateTypePickerFromClick (e) {
    const type = e.currentTarget.id.replace('Picker', '')
    this.selectType(type)
  }
})
